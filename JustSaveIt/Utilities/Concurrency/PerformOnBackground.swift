
import Foundation

class PerformOnBackground {
    static let queue = DispatchQueue.global()
    
    public static func async(_ callback: @escaping () -> Void) {
        queue.async {
            callback()
        }
    }
    
    public static func async(afterDelay delay: Double, _ callback: @escaping () -> Void) {
        let delaySec = delay >= 0 ? delay : 0
        
        queue.asyncAfter(deadline: DispatchTime.now() + delaySec, execute: callback)
    }
    
    // Async if caller is main thread, otherwise perform sync.
    public static func asyncOnlyIfMain(_ callback: @escaping () -> Void) {
        if Thread.isMainThread {
            queue.async {
                callback()
            }
        } else {
            callback()
        }
    }
}
