//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI

struct AddVerificationSuccessView: View {
    @Environment(Model.self) private var model
 
    let verifierName: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Image(systemName: "checkmark.seal.text.page")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
                .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
            Text("Complete!")
                .font(.largeTitle).bold()
                .multilineTextAlignment(.center)
            Text("The requested credential details has been verified.")
                .font(.body)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .center) {
                HStack {
                    Text("Verifier name:")
                        .fontWeight(.semibold)
                    Text(verifierName)
                }
            }
            
            Spacer()
            
            Button("Done") {
                model.proofRequestIsPresented.toggle()
            }
            .buttonStyle(.fullWidth)
        }
        .padding()
        .contentMargins(20, for: .scrollContent)
        .interactiveDismissDisabled()
    }
}

#Preview {
    AddVerificationSuccessView(verifierName: "Some Issuer")
        .environment(Model())
}
