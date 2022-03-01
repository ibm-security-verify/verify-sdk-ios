//
// Copyright contributors to the IBM Security Verify Core SDK for iOS project
//
import Foundation

extension String {    
    /// A representation of the string suitable for url form encoding.
    ///
    /// The encoding supports Base-64 string values.   Does not include "?" or "/" with respect to [RFC 3986 Section 3.4](https://datatracker.ietf.org/doc/html/rfc3986#section-3.4).
    public var urlFormEncodedString: String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? self
    }
}
