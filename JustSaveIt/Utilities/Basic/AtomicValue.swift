
import Foundation

struct AtomicValue<T> {
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
    
    public mutating func set(_ r: T) {
        enterLock()
        self._value = r
        leaveLock()
    }
    
    public mutating func getAndSet(_ r: T) -> T {
        enterLock()
        let old = self._value
        self._value = r
        leaveLock()
        
        return old
    }
    
    public mutating func setAndGet(_ r: T) -> T {
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
    
    public mutating func perform(_ callback: (inout T) -> Void) {
        enterLock()
        
        defer {
            leaveLock()
        }
        
        callback(&self._value)
    }
    
    private func enterLock() {
        objc_sync_enter(_lock)
    }
    
    private func leaveLock() {
        objc_sync_exit(_lock)
    }
}
