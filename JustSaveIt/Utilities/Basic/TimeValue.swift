
import Foundation

struct TimeValue: Codable, Hashable, Equatable, CustomStringConvertible {
    enum TimeType {
        case ms
        case sec
        case minutes
        case hours
        case days
    }
    
    public static let zero = TimeValue()
    
    let value: Double
    
    var description: String {
        return toString()
    }
    
    init() {
        self.value = 0
    }
    
    init<T:BinaryInteger>(ms milliseconds: T) {
        self.value = Double(Double(milliseconds) / 1000.0)
    }
    
    init(seconds: Double) {
        self.value = Double(seconds)
    }
    
    init(minutes: Double) {
        self.value = Double(minutes * 60.0)
    }
    
    init(hours: Double) {
        self.value = Double(hours * 60.0 * 60.0)
    }
    
    init(days: Double) {
        self.value = Double(days * 60.0 * 60.0 * 24.0)
    }
    
    var isZero: Bool {
        return value == 0
    }
    
    var inMS: Double {
        return value * 1000.0
    }
    var inSeconds: Double {
        return value
    }
    var inMinutes: Double {
        return self.inSeconds / 60.0
    }
    var inHours: Double {
        return self.inMinutes / 60.0
    }
    var inDays: Double {
        return self.inHours / 24.0
    }
    
    var secondsAsString: String {
        return String(format: "%.0f", self.inSeconds)
    }
    
    func toString() -> String {
        let days = self.inDays
        
        if days >= 1.0 {
            return toStringDays(days)
        }
        
        let hours = self.inHours
        
        if hours >= 1.0 {
            return toStringHours(hours)
        }
        
        let minutes = self.inMinutes
        
        if minutes >= 1.0 {
            return toStringMin(minutes)
        }
        
        let seconds = self.inSeconds
        
        return toStringSec(seconds)
    }
    
    func toStringMS(_ ms: Double?=nil) -> String {
        let milliseconds = ms ?? self.inMS
        return String(format: "%.1f ms", milliseconds)
    }
    
    func toStringSec(_ s: Double?=nil) -> String {
        let seconds = s ?? self.inSeconds
        return String(format: "%.1f seconds", seconds)
    }
    
    func toStringMin(_ m: Double?=nil) -> String {
        let min = m ?? self.inMinutes
        return String(format: "%.1f minutes", min)
    }
    
    func toStringHours(_ h: Double?=nil) -> String {
        let hours = h ?? self.inHours
        return String(format: "%.1f hours", hours)
    }
    
    func toStringDays(_ d: Double?=nil) -> String {
        let days = d ?? self.inDays
        return String(format: "%.1f days", days)
    }
    
    func toStringTimerStyle() -> String {
        return TimeValue.secondsToSecondsMinutesHoursString(self.inSeconds)
    }
    
    static func secondsToSecondsMinutesHours(_ seconds : Double) -> (Int, Int, Int) {
        let secondsInt = Int(seconds)
        let sec = (secondsInt % 3600) % 60
        let min = (secondsInt % 3600) / 60
        let hour = secondsInt / 3600
        return (sec, min, hour)
    }
    
    static func secondsToSecondsMinutesHoursString(_ seconds : Double) -> String {
        let timeValues = TimeValue.secondsToSecondsMinutesHours(seconds)
        
        if timeValues.1 <= 0 && timeValues.2 <= 0 {
            return String(format: "0:%02d", timeValues.0)
        }
        
        if timeValues.2 <= 0 {
            return String(format: "%02d:%02d", timeValues.1, timeValues.0)
        }
        
        return String(format: "%02d:%02d:%02d", timeValues.2, timeValues.1, timeValues.0)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.value)
    }
    
    internal enum CodingKeys: String, CodingKey {
        case value
    }
    
    static func +(left: TimeValue, right: TimeValue) -> Double {
        return left.value + right.value
    }

    static func -(left: TimeValue, right: TimeValue) -> Double {
        return left.value - right.value
    }

    static func *(left: TimeValue, right: TimeValue) -> Double {
        return left.value * right.value
    }

    static func /(left: TimeValue, right: TimeValue) -> Double {
        return left.value / right.value
    }

    static func ==(left: TimeValue, right: TimeValue) -> Bool {
        return left.value == right.value
    }

    static func !=(left: TimeValue, right: TimeValue) -> Bool {
        return left.value != right.value
    }

    static func <(left: TimeValue, right: TimeValue) -> Bool {
        return left.value < right.value
    }

    static func <=(left: TimeValue, right: TimeValue) -> Bool {
        return left.value <= right.value
    }

    static func >(left: TimeValue, right: TimeValue) -> Bool {
        return left.value > right.value
    }

    static func >=(left: TimeValue, right: TimeValue) -> Bool {
        return left.value >= right.value
    }
}
