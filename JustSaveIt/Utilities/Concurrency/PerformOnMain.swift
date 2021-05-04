
import Foundation

class PerformOnMain {
    static let queue = DispatchQueue.main
    
    // Performs the block now if caller is on main, or async if we are not.
    public static func perform(_ callback: @escaping () -> Void) {
        if Thread.isMainThread {
            callback()
        } else {
            async(callback)
        }
    }
    
    @discardableResult
    public static func sync<T>(_ callback: () -> T) -> T {
        if Thread.isMainThread {
            return callback()
        } else {
            return queue.sync {
                return callback()
            }
        }
    }
    
    public static func sync(_ callback: @escaping () -> Void) {
        if Thread.isMainThread {
            callback()
        } else {
            queue.sync {
                callback()
            }
        }
    }
    
    public static func async(_ callback: @escaping () -> Void) {
        queue.async {
            callback()
        }
    }
    
    public static func async(afterDelay delay: Double, _ callback: @escaping () -> Void) {
        let delaySec = delay >= 0 ? delay : 0
        
        queue.asyncAfter(deadline: DispatchTime.now() + delaySec, execute: callback)
    }
}
