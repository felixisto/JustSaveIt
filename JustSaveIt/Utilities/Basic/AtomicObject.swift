
import Foundation

class AtomicObject<T> {
    var value: T {
        get {
            enterLock()
            let copy = self._value
            leaveLock()
            return copy
        }
        set {
            self.set(newValue)
        }
    }
    
    private var _lock = NSObject()
    
    private var _value: T
    
    init(_ value: T) {
        self._value = value
    }
    
    public func set(_ r: T) {
        enterLock()
        self._value = r
        leaveLock()
    }
    
    public func getAndSet(_ r: T) -> T {
        enterLock()
        let old = self._value
        self._value = r
        leaveLock()
        
        return old
    }
    
    public func setAndGet(_ r: T) -> T {
        enterLock()
        self._value = r
        leaveLock()
        
        return r
    }
    
    public func perform(_ callback: () -> Void) {
        enterLock()
        
        defer {
            leaveLock()
        }
        
        callback()
    }
    
    public func perform(_ callback: (T) -> Void) {
        enterLock()
        
        defer {
            leaveLock()
        }
        
        callback(self._value)
    }
    
    private func enterLock() {
        objc_sync_enter(_lock)
    }
    
    private func leaveLock() {
        objc_sync_exit(_lock)
    }
}
