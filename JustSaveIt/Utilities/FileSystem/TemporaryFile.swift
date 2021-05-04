
import Foundation

enum TemporaryFileError: Error {
    case unknown
    case notEnoughSpace
    case requestedStoredDataNotFound
    case forbiddenLabel
}

/*
 * A temporary file, owned by our app.
 *
 * The temporary file does NOT release automatically on dealloc.
 */
struct TemporaryFile {
    weak var subscriptionManager: StorageFileOwnershipManager?
    weak var owner: AnyObject?
    let path: FilePath
    
    var exists: Bool {
        return SimpleFileSystem.shared.fileExists(at: path.url)
    }
    
    var size: DataSize {
        return SimpleFileSystem.shared.fileSize(of: path.url)
    }
    
    init(path: FilePath, owner: AnyObject?, subscriptionManager: StorageFileOwnershipManager?) {
        self.path = path
        self.owner = owner
        self.subscriptionManager = subscriptionManager
    }
    
    func retain() {
        if let ownership = self.owner {
            self.subscriptionManager?.subscribeClient(forFileURL: self.path, ownership: ownership)
        }
    }
    
    func release() {
        if let ownership = self.owner {
            self.subscriptionManager?.unsubscribeClient(fromFileURL: self.path, ownership: ownership)
        }
    }
    
    func retain(with owner: AnyObject?) -> TemporaryFile {
        let file = TemporaryFile(path: path, owner: owner, subscriptionManager: self.subscriptionManager)
        file.retain()
        return file
    }
}

struct TemporaryFileBinding {
    weak var owner: AnyObject?
    weak var manager: TemporaryFileManager?
    
    init(owner: AnyObject?, manager: TemporaryFileManager?) {
        self.owner = owner
        self.manager = manager
    }
}

/*
 * Files are deleted all the time, subscribe to a file url, in order to prevent deletion.
 * When finished using the file, unsubscribe.
 */
protocol StorageFileOwnershipManager: AnyObject {
    func subscribeClient(forFileURL url: FilePath, ownership: AnyObject)
    
    // Returns true if the file is still used. Returns false if the file was released.
    @discardableResult
    func unsubscribeClient(fromFileURL url: FilePath, ownership: AnyObject) -> Bool
}
