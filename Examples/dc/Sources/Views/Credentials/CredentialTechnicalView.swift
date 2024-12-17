///
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI
import DC

struct CredentialTechnicalView: View {
    var jsonRepresentation: Data = Data()
    
    /// The json for the credential.
    private var json: String {
        get {
            let object = try! JSONSerialization.jsonObject(with: jsonRepresentation)
            let prettyPrintedData = try! JSONSerialization.data(withJSONObject: object,options: [.prettyPrinted, .sortedKeys])
            
            return String(data: prettyPrintedData, encoding: .utf8)!
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text(json)
                    .monospaced()
                    .textSelection(.enabled)
                    .padding()
            }
            .padding()
        }
    }
}

#Preview {
    CredentialTechnicalView()
}
