//
// Copyright contributors to the IBM Security Verify Core SDK for iOS project
//

import Foundation

extension Data {
    /// Returns a Base-64 URL encoded string  as defined in [RFC4648](https://tools.ietf.org/html/rfc4648).
    /// - parameter options: The options to use for the encoding. Default value is `[]`.
    /// - returns: The Base-64 URL encoded string.
    public func base64UrlEncodedString(options: Data.Base64EncodingOptions = []) -> String {
        let result = base64EncodedString(options: options)
        return result.replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
