//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI

public struct InputTextFieldStyle: TextFieldStyle {
    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.body)
            .padding(12)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(12)
    }
}
