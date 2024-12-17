//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//
import SwiftUI
import DC

struct VerificationDetailView: View {
    var info: VerificationInfo
    
    var body: some View {
        List {
            Section(header: Text("General")) {
                LabeledContent("ID", value: info.id)
                LabeledContent("State", value: info.state.rawValue)
                LabeledContent("Role", value: info.role.rawValue)
                LabeledContent("Issuer DID", value: info.verifierDID)
            }
            Section(header: Text("Proof Requested")) {
                let metadata = proofRequestMetadata(verification: info)
                LabeledContent("Name", value: metadata.name)
                LabeledContent("Purpose", value: metadata.purpose)
                LabeledContent("Created", value: metadata.date.formatted(date: .abbreviated, time: .standard))
            }
            Section(header: Text("Credentials Provided")) {
                let metadata = proofCredentialMetadata(verification: info)
                ForEach(metadata) { item in
                    LabeledContent(item.id, value: item.value)
                }
            }
        }
    }
}

#Preview {
//VerificationDetailView()
}
