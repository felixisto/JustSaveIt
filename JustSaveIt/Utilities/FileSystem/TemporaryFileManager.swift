
import Foundation

/*
 * Manages temporary files.
 */
protocol TemporaryFileManager: StorageFileOwnershipManager {
    func hasFreeSpace(for size: DataSize) -> Bool
    
    // Creates a temporary file, with a unique name.
    // @label     Part of the temporary file's name.
    // @contents  Contents of the file.
    // @ownership Optional - adds an ownership, which prevents the temp file from being
    // deleted due to not being used.
    @discardableResult
    func createTemporaryFile(label: TemporaryFileLabel, contents: Data, ownership: AnyObject?) throws -> TemporaryFile
    
    @discardableResult
    func createTemporaryFile(label: TemporaryFileLabel, withContentsOf url: URL, ownership: AnyObject?) throws -> TemporaryFile
    
    func deleteTemporaryFile(at url: FilePath, reason: String)
    func eraseUnusedTemporaryFiles()
}

class TemporaryFileManagerStandard: TemporaryFileManager {
    let fileSystem: SimpleFileSystem
    let pathBuilder: FilePathBuilder
    let labelsAllowed: [TemporaryFileLabel]
    
    private let lock = SimpleLock()
    
    private var _fileSubscriptions: [StorageFileOwnershipManagerSub] = []
    
    init(fileSystem: SimpleFileSystem, tempPathBuilder: FilePathBuilder, labelsAllowed: [TemporaryFileLabel]) {
        self.fileSystem = fileSystem
        self.pathBuilder = tempPathBuilder
        self.labelsAllowed = labelsAllowed
    }
    
    // # TemporaryFileManager
    
    func isLowOnSpace() -> Bool {
        return fileSystem.isLowOnSpace()
    }
    
    func hasFreeSpace(for size: DataSize) -> Bool {
        return fileSystem.hasFreeSpace(for: size)
    }
    
    @discardableResult
    func createTemporaryFile(label: TemporaryFileLabel, contents: Data, ownership: AnyObject?) throws -> TemporaryFile {
        if !labelsAllowed.contains(label) {
            throw TemporaryFileError.forbiddenLabel
        }
        
        if !hasFreeSpace(for: DataSize(bytes: contents.count)) {
            throw TemporaryFileError.notEnoughSpace
        }
        
        guard let url = addTemporaryFile(label: label.asFileExtension(), contents: contents, ownership: ownership) else {
            throw TemporaryFileError.unknown
        }
        
        return TemporaryFile(path: url, owner: ownership, subscriptionManager: self)
    }
    
    @discardableResult
    func createTemporaryFile(label: TemporaryFileLabel, withContentsOf url: URL, ownership: AnyObject?) throws -> TemporaryFile {
        if !labelsAllowed.contains(label) {
            throw TemporaryFileError.forbiddenLabel
        }
        guard let url = copyTemporaryFile(label: label.asFileExtension(), withContentsOf: url, ownership: ownership) else {
            throw TemporaryFileError.unknown
        }
        
        return TemporaryFile(path: url, owner: ownership, subscriptionManager: self)
    }
    
    func deleteTemporaryFile(at path: FilePath, reason: String) {
        deleteTemporaryFile(at: path.url, reason: reason)
    }
    
    func deleteTemporaryFile(at url: URL, reason: String) {
        try? fileSystem.deleteItem(at: url, reason: reason)
    }
    
    func eraseUnusedTemporaryFiles() {
        let dirPath = pathBuilder.base
        
        guard var paths = try? fileSystem.filesOnlyContents(ofDirectory: dirPath) else {
            return
        }
        
        let totalCount = paths.count
        var deletedCount = 0
        
        paths = paths.filter({ (url) -> Bool in
            var hasSuffix = false
            
            labelsAllowed.forEach({ (label) in
                if url.path.hasSuffix(label.asFileExtension()) {
                    hasSuffix = true
                }
            })
            
            if !hasSuffix {
                return false
            }
            
            guard let path = try? pathBuilder.build(with: url.lastPathComponent) else {
                return false
            }
            
            guard let subscription = retrieveSubscription(for: path) else {
                return true
            }
            
            return subscription.counter == 0
        })
        
        let reason = "storage deleting unused temp file"
        
        for url in paths {
            deleteTemporaryFile(at: url, reason: reason)
            
            deletedCount += 1
            
            DebugLogging.logMessage(self, "Delete unused temporary file \(url)")
        }
        
        if deletedCount > 0 {
            DebugLogging.logMessage(self, "Deleted \(deletedCount) unused out of \(totalCount) temporary files")
        }
    }
    
    func retain(_ file: TemporaryFile) {
        if let ownership = file.owner {
            subscribeClient(forFileURL: file.path, ownership: ownership)
        }
    }
    
    func release(_ file: TemporaryFile) {
        if let ownership = file.owner {
            unsubscribeClient(fromFileURL: file.path, ownership: ownership)
        }
    }
    
    // # File management
    
    func addTemporaryFile(label: String, contents: Data, ownership: AnyObject?=nil) -> FilePath? {
        let name = fileSystem.generateTempFileName(suffix: label)
        
        guard let tempPath = try? pathBuilder.build(with: name) else {
            return nil
        }
        
        if fileSystem.fileExists(at: tempPath.url) {
            deleteTemporaryFile(at: tempPath.url, reason: "storage deleting temp \(label)")
        }
        
        if let owner = ownership {
            subscribeClient(forFileURL: tempPath, ownership: owner)
        }
        
        do {
            try fileSystem.createFile(at: tempPath.url, contents: contents, attributes: nil, reason: "storage creating temp \(label)")
        } catch let e {
            DebugLogging.logError(self, "Failed to create temporary file at \(tempPath.filePath); error: \(e)")
            return nil
        }
        
        return tempPath
    }
    
    func copyTemporaryFile(label: String, withContentsOf url: URL, ownership: AnyObject?=nil) -> FilePath? {
        let name = fileSystem.generateTempFileName(suffix: label)
        
        guard let tempPath = try? pathBuilder.build(with: name) else {
            return nil
        }
        
        if let owner = ownership {
            subscribeClient(forFileURL: tempPath, ownership: owner)
        }
        
        do {
            try fileSystem.copyFile(from: url, to: tempPath.url, overwrite: true, reason: "storage temporary file creation from origin source")
        } catch let e {
            DebugLogging.logError(self, "Failed to copy data to temporary file at \(tempPath.filePath); error: \(e)")
            return nil
        }
        
        return tempPath
    }
    
    // # StorageFileOwnershipManager
    
    func subscribeClient(forFileURL url: FilePath, ownership: AnyObject) {
        cleanupUnusedSubscriptions()
        
        let currentSub = retrieveSubscription(for: url)
        
        lock.perform {
            if let sub = currentSub {
                sub.addOwnership(ownership)
            } else {
                let sub = StorageFileOwnershipManagerSub(url)
                _fileSubscriptions.append(sub)
                sub.addOwnership(ownership)
            }
        }
    }
    
    @discardableResult
    func unsubscribeClient(fromFileURL url: FilePath, ownership: AnyObject) -> Bool {
        var result = true
        let currentSub = retrieveSubscription(for: url)
        
        guard let sub = currentSub else {
            return false
        }
        
        lock.perform {
            sub.removeOwnership(ownership)
            
            // Remove completely, if this is the last client
            _fileSubscriptions.removeAll { (element) -> Bool in
                return element == sub && sub.counter == 0
            }
            
            if retrieveSubscription(for: url) == nil {
                releaseFile(sub)
                
                result = false
            }
        }
        
        cleanupUnusedSubscriptions()
        
        return result
    }
    
    func cleanupUnusedSubscriptions() {
        lock.perform {
            _fileSubscriptions.removeAll { (element) -> Bool in
                return element.counter == 0
            }
        }
    }
    
    func retrieveSubscription(for path: FilePath) -> StorageFileOwnershipManagerSub? {
        let possibleSub = StorageFileOwnershipManagerSub(path)
        
        return retrieveMatchingSubscription(for: possibleSub)
    }
    
    func retrieveMatchingSubscription(for prototype: StorageFileOwnershipManagerSub) -> StorageFileOwnershipManagerSub? {
        var found: StorageFileOwnershipManagerSub?
        
        lock.perform {
            for sub in _fileSubscriptions {
                if sub == prototype {
                    found = sub
                    break
                }
            }
        }
        
        return found
    }
    
    func releaseFile(_ sub: StorageFileOwnershipManagerSub) {
        deleteTemporaryFile(at: sub.url, reason: "storage deleting unused temp file")
    }
}

struct StorageFileOwnershipWeak: Equatable {
    weak var ownership: AnyObject?
    
    var isNil: Bool {
        return ownership == nil
    }
    
    init(_ ownership: AnyObject?) {
        self.ownership = ownership
    }
    
    static func == (lhs: StorageFileOwnershipWeak, rhs: StorageFileOwnershipWeak) -> Bool {
        return lhs.ownership === rhs.ownership
    }
}

/*
 * File ownership manager subscriber.
 *
 * Thread safe: yes (lock)
 */
class StorageFileOwnershipManagerSub: Equatable {
    let path: FilePath
    
    var url: URL {
        return path.url
    }
    
    var ownership: [StorageFileOwnershipWeak] {
        return lock.perform {
            return self._ownership
        }
    }
    
    private let lock = SimpleLock()
    
    private var _ownership: [StorageFileOwnershipWeak] = []
    
    var counter: UInt {
        cleanup()
        return UInt(ownership.count)
    }
    
    init(_ path: FilePath) {
        self.path = path
    }
    
    func cleanup() {
        lock.perform {
            _ownership.removeAll { (weak: StorageFileOwnershipWeak) -> Bool in
                return weak.isNil
            }
        }
    }
    
    func addOwnership(_ ownership: AnyObject) {
        let ownershipObject = StorageFileOwnershipWeak(ownership)
        
        lock.perform {
            // Skip if already owned by the same object
            for own in _ownership {
                if own == ownershipObject {
                    return
                }
            }
            
            _ownership.append(ownershipObject)
        }
        
        cleanup()
    }
    
    func removeOwnership(_ ownership: AnyObject) {
        let ownershipObject = StorageFileOwnershipWeak(ownership)
        
        lock.perform {
            // Remove and cleanup
            _ownership.removeAll { (weak: StorageFileOwnershipWeak) -> Bool in
                return weak.isNil || weak == ownershipObject
            }
        }
    }
    
    public static func ==(_ a: StorageFileOwnershipManagerSub, _ b: StorageFileOwnershipManagerSub) -> Bool {
        return a.path.equals(b.path)
    }
}
