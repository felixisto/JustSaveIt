
import Foundation

/*
 * Performs code inside trapping threads in a low level objc lock.
 *
 * Note: the lock is reentrant.
 */
class SimpleLock {
    var lockValue: Any
    
    init(lockValue: Any=NSObject()) {
        self.lockValue = lockValue
    }
    
    public func perform<T>(_ callback: () -> T) -> T {
        lock()
        
        defer {
            unlock()
        }
        
        return callback()
    }
    
    public func perform<T>(_ callback: () throws -> T) throws -> T {
        lock()
        
        defer {
            unlock()
        }
        
        return try callback()
    }
    
    func lock() {
        objc_sync_enter(self.lockValue)
    }
    
    func unlock() {
        objc_sync_exit(self.lockValue)
    }
}
