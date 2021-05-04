
import Foundation

struct DataSize: Codable, Hashable, Equatable, CustomStringConvertible {
    enum SizeType {
        case bytes
        case KB
        case MB
        case GB
        case TB
    }
    
    public static let zero = DataSize()
    
    let value: UInt
    
    var description: String {
        return toString()
    }
    
    init() {
        self.value = 0
    }
    
    init<T:BinaryInteger>(bytes: T) {
        self.value = UInt(bytes)
    }
    
    init(bytes: Double) {
        self.value = UInt(bytes)
    }
    
    init(KB: Double) {
        self.value = UInt(KB * 1024)
    }
    
    init(MB: Double) {
        self.value = UInt(MB * 1024 * 1024)
    }
    
    init(GB: Double) {
        self.value = UInt(GB * 1024 * 1024 * 1024)
    }
    
    var isZero: Bool {
        get {
            return value == 0
        }
    }
    
    var inBytes: UInt {
        get {
            return value
        }
    }
    var inKB: Double {
        get {
            return Double(self.inBytes) / 1024
        }
    }
    var inMB: Double {
        get {
            return self.inKB / 1024
        }
    }
    var inGB: Double {
        get {
            return self.inMB / 1024
        }
    }
    var inTB: Double {
        get {
            return self.inGB / 1024
        }
    }
    
    var bytesAsString: String {
        get {
            return String(self.inBytes)
        }
    }
    
    func toString(forceType: DataSize.SizeType?=nil) -> String {
        let tb = self.inTB
        
        if tb >= 1.0 {
            return toStringTB(tb)
        }
        
        let gb = self.inGB
        
        if gb >= 1.0 {
            return toStringGB(gb)
        }
        
        let mb = self.inMB
        
        if mb >= 1.0 {
            return toStringMB(mb)
        }
        
        let kb = self.inKB
        
        if kb >= 1.0 {
            return toStringKB(kb)
        }
        
        let bytes = self.inBytes
        
        return toStringBytes(bytes)
        
    }
    
    func toStringTB(_ tb: Double?=nil) -> String {
        let value = tb ?? self.inTB
        
        return String(format: "%.1f TB", value)
    }
    
    func toStringGB(_ gb: Double?=nil) -> String {
        let value = gb ?? self.inGB
        
        return String(format: "%.1f GB", value)
    }
    
    func toStringMB(_ mb: Double?=nil) -> String {
        let value = mb ?? self.inMB
        
        return String(format: "%.1f MB", value)
    }
    
    func toStringKB(_ kb: Double?=nil) -> String {
        let value = kb ?? self.inKB
        
        return String(format: "%.1f KB", value)
    }
    
    func toStringBytes(_ bytes: UInt?=nil) -> String {
        let value = bytes ?? self.inBytes
        
        return String(format: "%d bytes", value)
    }
    
    func progress(outOf data: DataSize, use100: Bool=false) -> Double {
        let otherBytes = data.inBytes
        
        if otherBytes == 0 {
            return 0
        }
        
        let thisBytes = self.inBytes
        
        if thisBytes == 0 {
            return 0
        }
        
        let result = Double(thisBytes) / Double(otherBytes)
        
        return result * (use100 ? 100.0 : 1.0)
    }
    
    func add(_ value: Int) -> DataSize {
        return DataSize(bytes: self.value + UInt(value))
    }
    
    func add(_ value: UInt) -> DataSize {
        return DataSize(bytes: self.value + value)
    }
    
    func multiply(by value: Double) -> DataSize {
        let kb = self.inKB * value
        return DataSize(bytes: Int(kb) * 1024)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.value)
    }
    
    internal enum CodingKeys: String, CodingKey {
        case value
    }
    
    static func +(left: DataSize, right: DataSize) -> DataSize {
        return DataSize(bytes: left.value + right.value)
    }

    static func -(left: DataSize, right: DataSize) -> DataSize {
        return DataSize(bytes: left.value - right.value)
    }

    static func *(left: DataSize, right: DataSize) -> DataSize {
        return DataSize(bytes: left.value * right.value)
    }

    static func /(left: DataSize, right: DataSize) -> Double {
        return Double(left.value) / Double(right.value)
    }

    static func ==(left: DataSize, right: DataSize) -> Bool {
        return left.value == right.value
    }

    static func !=(left: DataSize, right: DataSize) -> Bool {
        return left.value != right.value
    }

    static func <(left: DataSize, right: DataSize) -> Bool {
        return left.value < right.value
    }

    static func <=(left: DataSize, right: DataSize) -> Bool {
        return left.value <= right.value
    }

    static func >(left: DataSize, right: DataSize) -> Bool {
        return left.value > right.value
    }

    static func >=(left: DataSize, right: DataSize) -> Bool {
        return left.value >= right.value
    }
}
