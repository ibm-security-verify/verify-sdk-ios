//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI
import DC

struct VerificationItemView: View {
    let info: VerificationInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal")
                    .foregroundStyle(Color(UIColor.systemBlue))
                    .font(.title)
                VStack(alignment: .leading) {
                    let header = proofRequestMetadata(verification: info)
                    Text(header.name)
                        .font(.body).fontWeight(.medium)
                    Text(header.date.formatted(date: .abbreviated, time: .standard))
                        .font(.subheadline).foregroundStyle(.gray)
                }
            }
        }
    }
}

#Preview {
    //VerificationItemView()
}
