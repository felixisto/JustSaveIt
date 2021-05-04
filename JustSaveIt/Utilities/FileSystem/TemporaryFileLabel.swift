
import Foundation

enum TemporaryFileLabel: String, CaseIterable {
    // Generic
    case temp = ".temp"
    
    func asFileExtension() -> String {
        return self.rawValue
    }
}
