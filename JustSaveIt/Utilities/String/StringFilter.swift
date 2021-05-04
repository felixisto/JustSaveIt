
import Foundation

// Filters strings based on given query.
// Filter is broken into whitelist (allowed words) and blacklist (fobidden words).
// Allowed words are any words separated by whitespace.
// Forbidden words are any words separated by whitespace and with "-" prefix.
// Examples:
// test one / whitelist = [test,one]
// test one -two / whitelist = [test,one] blacklist = [two]
class StringFilter {
    public static let BLACKLIST_WORD_PREFIX = "-"
    
    private var _query: String = ""
    private var _queryWords: [String] = []
    
    var query: String {
        get {
            return _query
        }
        set {
            _query = processQueryForUsage(newValue)
            _queryWords = _query.splitWords()
        }
    }
    
    var blacklistWordPrefix = StringFilter.BLACKLIST_WORD_PREFIX
    
    // Autocomputed based on @value.
    var whitelist: [String] {
        if blacklistWordPrefix.isEmpty {
            return _queryWords
        }
        
        return _queryWords.filter { (string) -> Bool in
            return !string.hasPrefix(blacklistWordPrefix)
        }
    }
    
    // Autocomputed based on @value.
    var blacklist: [String] {
        if blacklistWordPrefix.isEmpty {
            return []
        }
        
        let words = _queryWords.filter { (string) -> Bool in
            return string.hasPrefix(blacklistWordPrefix)
        }
        
        var result: [String] = []
        
        for word in words {
            result.append(word.replacingOccurrences(of: blacklistWordPrefix, with: ""))
        }
        
        return result
    }
    
    // Letter casing will be ignored
    var ignoreCasing = true
    
    // Query words must match exactly the words or just parts of them?
    var mustMatchWholeCase = false
    
    init() {
        
    }
    
    init(query: String) {
        self.query = query
    }
    
    // Returns true if given string is allowed by the filter.
    func isAllowed(_ string: String) -> Bool {
        // Target
        var target = processTargetStringForUsage(string).splitWords()
        
        if ignoreCasing {
            target = target.map({ (string) -> String in
                return string.lowercased()
            })
        }
        
        var containsAllowed = 0
        
        // Allowed
        var whitelist = self.whitelist
        
        if ignoreCasing {
            whitelist = whitelist.map({ (string) -> String in
                return string.lowercased()
            })
        }
        
        for allowed in whitelist {
            if isTarget(target, matching: allowed) {
                containsAllowed += 1
            }
        }
        
        if !whitelist.isEmpty && containsAllowed == 0 {
            return false
        }
        
        // Forbidden
        var containsForbidden = 0
        
        var blacklist = self.blacklist
        
        if ignoreCasing {
            blacklist = blacklist.map({ (string) -> String in
                return string.lowercased()
            })
        }
        
        for forbidden in blacklist {
            if isTarget(target, matching: forbidden) {
                containsForbidden += 1
            }
        }
        
        if !blacklist.isEmpty && containsForbidden > 0 {
            return false
        }
        
        return true
    }
    
    func isTarget(_ target: [String], matching word: String) -> Bool {
        return target.contains { (element) -> Bool in
            if self.mustMatchWholeCase {
                return element == word
            } else {
                return element.contains(word)
            }
        }
    }
    
    // Removes undesired characters and other expressions from the query.
    func processQueryForUsage(_ string: String) -> String {
        return string.condenseWhitespaceAndNewlines()
    }
    
    func processTargetStringForUsage(_ string: String) -> String {
        return string.condenseWhitespaceAndNewlines()
    }
}
