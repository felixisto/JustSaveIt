
import Foundation

// Prints messages to the standard output.
class DebugLogging {
    public static let ENABLED = true

    func message<T>(_ source: T, _ message: String) {
        DebugLogging.logMessage(source, message)
    }

    func warning<T>(_ source: T, _ message: String) {
        DebugLogging.logWarning(source, message)
    }

    func error<T>(_ source: T, _ message: String) {
        DebugLogging.logError(source, message)
    }
    
    public static func logMessage<T>(_ source: T, _ message: String) {
        if !DebugLogging.ENABLED {
            return
        }
        
        let label = getLabel(of: source)
        logMessage(label: label, message)
    }
    
    public static func logWarning<T>(_ source: T, _ message: String) {
        if !DebugLogging.ENABLED {
            return
        }
        
        let label = getLabel(of: source)
        logWarning(label: label, message)
    }
    
    public static func logError<T>(_ source: T, _ message: String) {
        if !DebugLogging.ENABLED {
            return
        }
        
        let label = getLabel(of: source)
        logError(label: label, message)
    }
    
    public static func logMessage(label: String, _ message: String) {
        if !DebugLogging.ENABLED {
            return
        }
        
        print("\(getTimestamp())|MESSAGE|\(label)| \(message)")
    }
    
    public static func logWarning(label: String, _ message: String) {
        if !DebugLogging.ENABLED {
            return
        }
        
        print("\(getTimestamp())|WARNING|\(label)| \(message)")
    }
    
    public static func logError(label: String, _ message: String) {
        if !DebugLogging.ENABLED {
            return
        }
        
        print("\(getTimestamp())|ERROR|\(label)| \(message)")
    }
    
    public static func getLabel(of source: Any) -> String {
        let typeValue = type(of: source)
        return String(describing: "\(typeValue)")
    }
    
    public static func getTimestamp() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSSS"
        return formatter.string(from: now)
    }
}
