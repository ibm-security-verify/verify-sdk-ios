//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import Core
import SwiftUI

/// An interface implemented by views displaying credential or verification in a preview.
protocol ViewDescriptor: View {
    /// The JSON representation of the preview data based on a credentail defination or proof request.
    ///
    /// A View implements this protocol to support it's presentation design.
    var jsonRepresentation: Data { get set }
}
