
import Foundation

enum SimpleFileSystemError: Error {
    case diskEncrypted
    case createFileFail
    case readSecureACFail
}

/*
 * Basic file system functionality.
 */
class SimpleFileSystem {
    public static let shared = SimpleFileSystem()
    
    public static let FREE_SPACE_MIN_REQUIREMENT = DataSize(MB: 500)
    
    public let logger: FileSystemUserLogging
    public let defaultFileAttributes: [FileAttributeKey : Any]
    
    private let lock = SimpleLock()
    
    private let fileSystem: FileManager = FileManager.default
    
    private let diskState = AtomicOptional<SimpleFileSystemDiskState>(nil)
    
    convenience init() {
        self.init(logger: FileSystemUserLogging())
    }
    
    init(logger: FileSystemUserLogging, defaultFileAttributes: [FileAttributeKey : Any]?=nil) {
        self.logger = logger
        self.defaultFileAttributes = defaultFileAttributes ?? [FileAttributeKey.protectionKey : FileProtectionType.complete]
    }
    
    // # Directory paths
    
    // Returns a path to a new generated temporary file. The file will be deleted automatically by OS.
    public func temporaryFileURL(contents: Data, withExtension ext: String = "temp") -> URL? {
        if self.isLowOnSpace() {
            return nil
        }
        
        let directory = NSTemporaryDirectory()
        var fileName = NSUUID().uuidString
        
        if !ext.isEmpty {
            fileName += ".\(ext)"
        }
        
        guard let tempURL = NSURL.fileURL(withPathComponents: [directory, fileName]) else {
            return nil
        }
        
        let result = fileSystem.createFile(atPath: tempURL.path, contents: contents, attributes: nil)
        
        if !result {
            return nil
        }
        
        return tempURL
    }
    
    public func documentsURL() -> URL {
        return path(withDirName: "")
    }
    
    public func documentsSubdirectoryURL(named: String) -> URL {
        return path(withDirName: named)
    }
    
    public func documentsSubdirectoryFileURL(directoryName: String, fileName: String) -> URL {
        var dirURL = path(withDirName: directoryName)
        dirURL.appendPathComponent(fileName)
        return dirURL
    }
    
    public func cacheDirURL() -> URL {
        return path(withDirName: "", baseDirectory: .cachesDirectory)
    }
    
    public func cacheDirSubdirectoryURL(named: String) -> URL {
        return path(withDirName: named, baseDirectory: .cachesDirectory)
    }
    
    public func cacheDirSubdirectoryFileURL(directoryName: String, fileName: String) -> URL {
        var dirURL = path(withDirName: directoryName, baseDirectory: .cachesDirectory)
        dirURL.appendPathComponent(fileName)
        return dirURL
    }
    
    // # File paths
    
    public func contents(ofDirectory url: URL) throws -> [URL] {
        return try fileSystem.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
    }
    
    public func filesOnlyContents(ofDirectory url: URL, recursive: Bool=false) throws -> [URL] {
        var result: [URL] = []
        let urls = try fileSystem.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        
        for subitemURL in urls {
            if isFile(at: subitemURL) {
                result.append(subitemURL)
            }
            if recursive && isDirectory(at: subitemURL) {
                let subdirectoryURLs = try filesOnlyContents(ofDirectory: subitemURL, recursive: recursive)
                result.append(contentsOf: subdirectoryURLs)
            }
        }
        
        return result
    }
    
    public func directoryOnlyContents(ofDirectory url: URL, recursive: Bool=false) throws -> [URL] {
        var result: [URL] = []
        let urls = try fileSystem.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        
        for subitemURL in urls {
            if isDirectory(at: subitemURL) {
                result.append(subitemURL)
                
                if recursive {
                    let subdirectoryURLs = try directoryOnlyContents(ofDirectory: subitemURL, recursive: recursive)
                    result.append(contentsOf: subdirectoryURLs)
                }
            }
        }
        
        return result
    }
    
    public func generateTempFileName(suffix: String) -> String {
        return String("\(Date().timeIntervalSince1970)\(suffix)")
    }
    
    // # Validators
    
    public func isLowOnSpace() -> Bool {
        return systemFreeSize() <= SimpleFileSystem.FREE_SPACE_MIN_REQUIREMENT
    }
    
    public func hasFreeSpace(for size: DataSize) -> Bool {
        return systemFreeSize() >= size + SimpleFileSystem.FREE_SPACE_MIN_REQUIREMENT
    }
    
    public func hasWritePermission(for path: URL) -> Bool {
        #if !TARGET_IS_EXTENSION
        return true
        #else
        return false
        #endif
    }
    
    public func fileExists(at path: URL) -> Bool {
        return performSafely {
            return fileSystem.fileExists(atPath: path.path)
        }
    }
    
    // Returns false if file or dir do not exist for given path.
    public func isFile(at path: URL) -> Bool {
        return performSafely {
            return _isFile(at: path)
        }
    }
    
    private func _isFile(at path: URL) -> Bool {
        var isDir : ObjCBool = false
        let exists = fileSystem.fileExists(atPath: path.path, isDirectory: &isDir)
        
        return exists && !isDir.boolValue
    }
    
    // Returns false if file or dir do not exist for given path.
    public func isDirectory(at path: URL) -> Bool {
        return performSafely {
            return _isDirectory(at: path)
        }
    }
    
    private func _isDirectory(at path: URL) -> Bool {
        var isDir : ObjCBool = false
        let exists = fileSystem.fileExists(atPath: path.path, isDirectory: &isDir)
        
        return exists && isDir.boolValue
    }
    
    // # Properties
    
    public func systemFreeSize() -> DataSize {
        do {
            let path = NSHomeDirectory() as String
            let systemAttributes = try fileSystem.attributesOfFileSystem(forPath: path)
            
            if let bytes = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return DataSize(bytes: bytes)
            }
        } catch {
            
        }
        
        return .zero
    }
    
    public func fileAttributes(of path: URL) -> [FileAttributeKey : Any] {
        if let attr = try? fileSystem.attributesOfItem(atPath: path.path) {
            return attr
        }
        
        return [:]
    }
    
    public func fileSize(of path: URL) -> DataSize {
        let bytes = fileAttributes(of: path)[.size] as? UInt ?? 0
        return DataSize(bytes: bytes)
    }
    
    public func directorySize(of path: URL) -> DataSize {
        var totalSize: UInt = 0
        
        if let allFiles = try? filesOnlyContents(ofDirectory: path, recursive: true) {
            for url in allFiles {
                totalSize += fileSize(of: url).inBytes
            }
        }
        
        return DataSize(bytes: totalSize)
    }
    
    public func dateCreated(of path: URL) -> Date? {
        return fileAttributes(of: path)[.creationDate] as? Date
    }
    
    public func dateModified(of path: URL) -> Date? {
        return fileAttributes(of: path)[.modificationDate] as? Date ?? dateCreated(of: path)
    }
    
    // # Operations
    
    public func createDirectory(at path: URL, reason: String="unknown") throws {
        try performSafely {
            if !self.isDiskAccessible {
                throw SimpleFileSystemError.diskEncrypted
            }
            
            do {
                try fileSystem.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
                logger.logVerbose_createDirectory(self, path: path, reason: reason)
            } catch let e {
                logger.log_createDirectoryFail(self, path: path, error: e, reason: reason)
                throw e
            }
        }
    }
    
    // If the file already exists, it will be overwritten.
    public func createFile(at path: URL, contents: Data, attributes: [FileAttributeKey : Any]?, reason: String="unknown") throws {
        try performSafely {
            if !self.isDiskAccessible {
                throw SimpleFileSystemError.diskEncrypted
            }
            
            let result = fileSystem.createFile(atPath: path.path, contents: contents, attributes: attributes ?? defaultFileAttributes)
            
            if !result {
                let e = SimpleFileSystemError.createFileFail
                logger.log_createFileFail(self, path: path, error: e, reason: reason)
                throw e
            }
            
            logger.logVerbose_createFile(self, path: path, reason: reason)
        }
    }
    
    public func readFromFile(at path: URL, options: Data.ReadingOptions=[], reason: String="unknown") throws -> Data {
        return try performSafely {
            if !self.isDiskAccessible {
                throw SimpleFileSystemError.diskEncrypted
            }
            
            do {
                let data = try Data(contentsOf: path, options: options)
                
                logger.logVerbose_readFile(self, path: path, length: data.count)
                
                return data
            } catch let e {
                logger.log_readFileFail(self, path: path, error: e, reason: reason)
                throw e
            }
        }
    }
    
    // Overwrites the contents of a file with the new given data.
    public func writeToFile(at path: URL, data: Data, reason: String="unknown") throws {
        try performSafely {
            if !self.isDiskAccessible {
                throw SimpleFileSystemError.diskEncrypted
            }
            
            let length = data.count
            
            do {
                try data.write(to: path, options: [.atomicWrite])
                logger.logVerbose_writeFile(self, path: path, length: length, reason: reason)
            } catch let e {
                logger.log_writeFileFail(self, path: path, length: length, error: e, reason: reason)
                throw e
            }
        }
    }
    
    // Appends the contents to the end of a file.
    public func appendToFile(at path: URL, data: Data, reason: String="unknown") throws {
        try performSafely {
            if !self.isDiskAccessible {
                throw SimpleFileSystemError.diskEncrypted
            }
            
            if let fileHandle = FileHandle(forWritingAtPath: path.path) {
                defer {
                    fileHandle.closeFile()
                }
                
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                
                logger.logVerbose_writeFile(self, path: path, length: data.count, reason: reason)
            }
            else {
                do {
                    try data.write(to: path, options: .atomicWrite)
                } catch let e {
                    logger.log_writeFileFail(self, path: path, length: data.count, error: e, reason: reason)
                    throw e
                }
            }
        }
    }
    
    public func copyFile(from origin: URL, to url: URL, overwrite: Bool, reason: String="unknown") throws {
        try performSafely {
            if !self.isDiskAccessible {
                throw SimpleFileSystemError.diskEncrypted
            }
            
            // Do not use replaceItemAt, it's garbage.
            if overwrite {
                try? fileSystem.removeItem(at: url)
            }
            
            do {
                try fileSystem.copyItem(atPath: origin.path, toPath: url.path)
            } catch let e {
                logger.log_copyFileFail(self, origin: origin, to: url, error: e, reason: reason)
                throw e
            }
            
            logger.logVerbose_copyFile(self, origin: origin, to: url, reason: reason)
        }
    }
    
    // Deletes file or folder.
    public func deleteItem(at path: URL, reason: String="unknown") throws {
        try performSafely {
            try fileSystem.removeItem(at: path)
            
            logger.logVerbose_deleteItem(self, path: path, reason: reason)
        }
    }
    
    // Deletes item if its a file.
    public func deleteFile(at path: URL, reason: String="unknown") throws {
        try performSafely {
            if !self._isFile(at: path) {
                return
            }
            
            try fileSystem.removeItem(at: path)
            
            logger.logVerbose_deleteItem(self, path: path, reason: reason)
        }
    }
    
    // # Synchronization
    
    public func performSafely<T>(_ callback: () ->T) -> T {
        self.lock.perform {
            callback()
        }
    }
    
    public func performSafely<T>(_ callback: () throws ->T) throws -> T {
        try self.lock.perform {
            try callback()
        }
    }
    
    // # Utils
    
    private func path(withDirName dirName: String, baseDirectory: FileManager.SearchPathDirectory = .documentDirectory) -> URL {
        var path = fileSystem.urls(for: baseDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: "")
        
        if !dirName.isEmpty {
            path = path.appendingPathComponent(dirName)
        }
        
        // Must be created
        performSafely {
            if !fileSystem.fileExists(atPath: path.path) {
                try? fileSystem.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
            }
        }
        
        return path
    }
}

protocol SimpleFileSystemDiskStateListener: class {
    func onDiskStateChange(isAccessible: Bool)
}

class SimpleFileSystemDiskState: SimpleFileSystemDiskStateListener {
    var isAccessible = AtomicValue<Bool>(true)
    
    func onDiskStateChange(isAccessible: Bool) {
        self.isAccessible.set(isAccessible)
    }
}

// Encryption state of the disk.
// SimpleFileSystem cannot detect on its own whether the disk is currently encrypted or not.
// To alert the SimpleFileSystem of disk state change, use @diskStateListener.
extension SimpleFileSystem {
    // If disk is encrypted, this will return false.
    var isDiskAccessible: Bool {
        return self.diskState.value?.isAccessible.value ?? true
    }
    
    // Used to set the disk state.
    // This property should be called only once per app session.
    var diskStateListener: SimpleFileSystemDiskStateListener {
        let state = SimpleFileSystemDiskState()
        
        let oldValue = self.diskState.getAndSet(state)
        
        if oldValue != nil {
            fatalError("Do not get more than one diskStateListener")
        }
        
        return state
    }
}
