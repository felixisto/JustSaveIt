
import Foundation

/*
 * Keeps track of time using one single time interval.
 *
 * Thread safe: yes
 */
class SimpleTimerLooper {
    let interval: TimeInterval
    
    var lastFireTime: Date? {
        return _lastFireTime.value
    }
    
    var isExpired: Bool {
        if let date = self.lastFireTime {
            return -date.timeIntervalSinceNow >= interval
        }
        
        return true
    }
    
    private var _lastFireTime = AtomicValue<Date?>(nil)
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    // Updates the timer. If not expired, nothing happens. If expired, the date is updated.
    // Performs the given block only if timer is expired.
    func update(_ block: () -> Void) {
        if self.isExpired {
            renew()
            
            block()
        }
    }
    
    func update(_ block: () throws -> Void) throws {
        if self.isExpired {
            renew()
            
            try block()
        }
    }
    
    // Sets all values to their defaults.
    func reset() {
        _lastFireTime.set(nil)
    }
    
    private func renew() {
        _lastFireTime.set(Date())
    }
}
