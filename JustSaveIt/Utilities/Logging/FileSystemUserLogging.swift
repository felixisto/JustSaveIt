
import Foundation

class FileSystemUserLogging {
    public static let LEVEL_DISABLED = 0 // Disable logs
    public static let LEVEL_STANDARD = 1 // Standard logs
    public static let LEVEL_VERBOSE = 2 // Verbose logs

    public static let LEVEL_DEFAULT = FileSystemUserLogging.LEVEL_STANDARD
    
    public static let shared = FileSystemUserLogging()

    private var _level: AtomicValue<Int> = AtomicValue<Int>(FileSystemUserLogging.LEVEL_DEFAULT)

    var level: Int {
        get {
            return _level.value
        }
        set {
            _level.set(newValue)
        }
    }

    var isLevelDisabled: Bool {
        return self.level <= FileSystemUserLogging.LEVEL_DISABLED
    }

    var isLevelStandard: Bool {
        return self.level <= FileSystemUserLogging.LEVEL_STANDARD
    }

    var isLevelVerbose: Bool {
        return self.level <= FileSystemUserLogging.LEVEL_VERBOSE
    }
    
    // # Wrap
    
    public func wrap(_ value: String) -> String {
        return value
    }
    
    public func wrapPath(_ value: String) -> String {
        return value
    }
    
    public func wrapError(_ value: String) -> String {
        return value
    }
    
    // # Logs message
    
    private func message<T>(_ source: T, _ message: String, level: Int=FileSystemUserLogging.LEVEL_STANDARD) {
        if level > self.level {
            return
        }
        
        DebugLogging.logMessage(source, message)
    }

    private func warning<T>(_ source: T, _ message: String, level: Int=FileSystemUserLogging.LEVEL_STANDARD) {
        if level > self.level {
            return
        }
        
        DebugLogging.logWarning(source, message)
    }

    private func error<T>(_ source: T, _ message: String, level: Int=FileSystemUserLogging.LEVEL_STANDARD) {
        if level > self.level {
            return
        }
        
        DebugLogging.logError(source, message)
    }
    
    // # Utilities
    
    public static func getLabel(of source: Any) -> String {
        let typeValue = type(of: source)
        return String(describing: "\(typeValue)")
    }
}

// SimpleFileSystem.swift
extension FileSystemUserLogging {
    public func logVerbose_createDirectory<T>(_ source: T, path: URL, reason: String="unknown") {
        // Optimization
        if self.isLevelDisabled {
            return
        }
        
        let safePath = wrapPath(path.path)
        message(source, "Created directory \(safePath); reason: \(reason)", level: FileSystemUserLogging.LEVEL_VERBOSE)
    }
    
    public func log_createDirectoryFail<T>(_ source: T, path: URL, error: Error, reason: String="unknown") {
        // Optimization
        if self.isLevelDisabled {
            return
        }
        
        let safePath = wrapPath(path.path)
        let safeError = wrapError(error.localizedDescription)
        message(source, "Failed to create directory \(safePath); reason: \(reason); error: \(safeError)")
    }
    
    public func logVerbose_createFile<T>(_ source: T, path: URL, reason: String="unknown") {
        // Optimization
        if self.isLevelDisabled {
            return
        }
        
        let safePath = wrapPath(path.path)
        message(source, "Created file \(safePath); reason: \(reason)", level: FileSystemUserLogging.LEVEL_VERBOSE)
    }
    
    public func log_createFileFail<T>(_ source: T, path: URL, error: Error, reason: String="unknown") {
        // Optimization
        if self.isLevelDisabled {
            return
        }
        
        let safePath = wrapPath(path.path)
        let safeError = wrapError(error.localizedDescription)
        message(source, "Failed to create file \(safePath); reason: \(reason); error: \(safeError)")
    }
    
    public func logVerbose_copyFile<T>(_ source: T, origin: URL, to dest: URL, reason: String="unknown") {
        // Optimization
        if self.isLevelDisabled {
            return
        }
        
        let safePath1 = wrapPath(origin.path)
        let safePath2 = wrapPath(dest.path)
        message(source, "Copied file from \(safePath1) to \(safePath2); reason: \(reason)")
    }
    
    public func log_copyFileFail<T>(_ source: T, origin: URL, to dest: URL, error: Error, reason: String="unknown") {
        // Optimization
        if self.isLevelDisabled {
            return
        }
        
        let safePath1 = wrapPath(origin.path)
        let safePath2 = wrapPath(dest.path)
        let safeError = wrapError(error.localizedDescription)
        message(source, "Failed to copy file from \(safePath1) to \(safePath2);; reason: \(reason); error: \(safeError)")
    }
    
    public func logVerbose_readFile<T>(_ source: T, path: URL, length: Int, reason: String="unknown") {
        // Optimization
        if self.isLevelDisabled {
            return
        }
        
        let safePath = wrapPath(path.path)
        message(source, "Read from file \(safePath); reason: \(reason); data size: \(length)", level: FileSystemUserLogging.LEVEL_VERBOSE)
    }
    
    public func log_readFileFail<T>(_ source: T, path: URL, error: Error, reason: String="unknown") {
        // Optimization
        if self.isLevelDisabled {
            return
        }
        
        let safePath = wrapPath(path.path)
        let safeError = wrapError(error.localizedDescription)
        message(source, "Failed to read from file \(safePath); reason: \(reason); error: \(safeError)")
    }
    
    public func logVerbose_writeFile<T>(_ source: T, path: URL, length: Int, reason: String="unknown") {
        // Optimization
        if self.isLevelDisabled {
            return
        }
        
        let safePath = wrapPath(path.path)
        message(source, "Wrote data to file \(safePath); data size: \(length); reason: \(reason)", level: FileSystemUserLogging.LEVEL_VERBOSE)
    }
    
    public func log_writeFileFail<T>(_ source: T, path: URL, length: Int, error: Error, reason: String="unknown") {
        // Optimization
        if self.isLevelDisabled {
            return
        }
        
        let safePath = wrapPath(path.path)
        let safeError = wrapError(error.localizedDescription)
        message(source, "Failed to write data to file \(safePath); data size: \(length); reason: \(reason); error: \(safeError)")
    }
    
    public func logVerbose_deleteItem<T>(_ source: T, path: URL, reason: String="unknown") {
        // Optimization
        if self.isLevelDisabled {
            return
        }
        
        let safePath = wrapPath(path.path)
        message(source, "Deleted item \(safePath); reason: \(reason)", level: FileSystemUserLogging.LEVEL_VERBOSE)
    }
}
