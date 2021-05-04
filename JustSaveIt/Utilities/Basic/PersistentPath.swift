
import Foundation

enum PersistentPathError: Error {
    case invalidPath
    case invalidDirectory
}

/*
 * Universal path, remains valid at all times.
 *
 * A common problem with paths is, they don't always stay valid after app relaunch,
 * so the full path may have to be corrected.
 */
protocol PersistentPath: AnyObject, NSCoding, CustomStringConvertible {
    // Non-persistent full path.
    var url: URL { get }
    
    // Persistent name, never changes. @url always ends with this value.
    var name: String { get }
    
    func equals(_ other: PersistentPath) -> Bool
}

extension PersistentPath {
    var description: String {
        return url.path
    }
}

/*
 * Persistent file path.
 */
protocol FilePath: PersistentPath {
    // Non-persistent directory path, that may change after app relaunch.
    var base: URL { get }
    
    // Convenience for self.url.path
    var filePath: String { get }
}

extension FilePath {
    var filePath: String {
        return self.url.path
    }
}

/*
 * Builds file paths.
 */
protocol FilePathBuilder {
    var base: URL { get }
    
    func build(with name: String) throws -> FilePath
}

/*
 * Persistent directory path.
 */
protocol DirectoryPath: PersistentPath {
    
}

class FilePathInvalid: FilePath {
    let url: URL = URL(fileURLWithPath: "")
    let name: String = ""
    let base: URL = URL(fileURLWithPath: "")
    let filePath: String = ""
    
    init() {
        
    }
    
    required init?(coder: NSCoder) {
        
    }
    
    func encode(with coder: NSCoder) {
        
    }
    
    func equals(_ other: PersistentPath) -> Bool {
        return false
    }
}
