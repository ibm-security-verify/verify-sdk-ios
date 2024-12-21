//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import Foundation

extension String {
    /// Convert a string from camel case to title case.
    /// ```swift
    /// print("firstName".camelToTitleCase)  // First Name
    var camelToTitleCase: String {
            replacing(#/[[:upper:]]/#) { " " + $0.output }.capitalized
        }
}
