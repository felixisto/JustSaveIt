
import Foundation

extension String {
    func equals(_ other: String) -> Bool {
        return self == other
    }
    
    func equalsIgnoreCasing(_ other: String) -> Bool {
        return self.caseInsensitiveCompare(other) == .orderedSame
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func indexOf(substring: String) -> Int? {
        return self.range(of: substring)?.lowerBound.utf16Offset(in: self)
    }
    
    func substring(from: Int, to: Int?=nil) -> String {
        if let to_ = to {
            let fromIndex = index(from: from)
            let toIndex = index(from: to_)
            return String(self[fromIndex..<toIndex])
        } else {
            let fromIndex = index(from: from)
            return String(self[fromIndex...])
        }
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    func split(by string: String) -> [String] {
        return self.components(separatedBy: string)
    }
    
    func splitWords() -> [String] {
        return split(by: " ")
    }
    
    func condenseWhitespaceAndNewlines() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}
