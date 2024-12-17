//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI

struct FullWidthButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.trigger() }) {
            configuration.label
                .frame(maxWidth: .infinity)
                .font(.body).bold()
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .safeAreaPadding()
    }
}

extension PrimitiveButtonStyle where Self == FullWidthButtonStyle {
    static var fullWidth: FullWidthButtonStyle {
        FullWidthButtonStyle()
    }
}
