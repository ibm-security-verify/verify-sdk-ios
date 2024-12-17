//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI
import DC

struct AddVerificationClaimsView: View {
    @Environment(Model.self) private var model
    @State private var canNavigate = false
    
    let preview: VerificationPreviewInfo
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Image(systemName: "checkmark.seal.text.page")
                .font(.largeTitle)
                .foregroundColor(.accentColor)

            Text("Identity Details")
                .font(.largeTitle).bold()
                .multilineTextAlignment(.center)
            
            VStack(alignment: .center, spacing: 16) {
//                if let verificationGenerated = model.verificationGenerated {
//                    let metadata = proofCredentialMetadata(verification: verificationGenerated)
//                    List {
//                        ForEach(metadata) { item in
//                            LabeledContent(item.id, value: item.value)
//                        }
//                    }
//                }
                proofRequestPresentation(preview)
                
                Spacer()
                Text("If you want to share identity details with \(preview.label ?? "Unknown"), tap **Allow Verification**.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .background(Color(UIColor.systemBackground))
            .scrollContentBackground(.hidden)
            
            Spacer()
            Button(action: {
                Task {
                    await model.verifyCredential(preview)
                    self.canNavigate.toggle()
                }
            }) {
                ZStack {
                    Image("busy")
                        .rotationEffect(.degrees(model.isProcessing ? 360.0 : 0.0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: model.isProcessing)
                        .opacity(model.isProcessing ? 1 : 0)
                    
                    Text("Allow Verification")
                        .opacity(model.isProcessing ? 0 : 1)
                        .frame(maxWidth:.infinity)
                }
            }
            .buttonStyle(.fullWidth)
            
            Button("Cancel") {
                model.proofRequestIsPresented.toggle()
            }
            .tint(.blue)
        }
        .padding()
        .contentMargins(20, for: .scrollContent)
        .interactiveDismissDisabled()
        .navigationDestination(isPresented: $canNavigate) {
            AddVerificationSuccessView(verifierName: preview.label ?? "Unknown")
        }
    }
    
    @ViewBuilder
    /// Obtain the view that will display the credential associated with the document type.
    /// - Parameters:
    ///  - credential: The credential to be previewed
    /// - Returns: The view associated with the document type.
    func proofRequestPresentation(_ info: VerificationPreviewInfo) -> some View {
        if let view = model.preview(for: .verifications, using: info) {
            view
        }
    }
}

//#Preview {
//    AddVerificationClaimsView(verification: nil)
//        .environment(Model())
//}
