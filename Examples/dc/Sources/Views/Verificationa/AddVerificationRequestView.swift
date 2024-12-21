//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI
import DC

struct AddVerificationRequestView: View {
    @Environment(Model.self) private var model
    @State private var canNavigate = false
    
    let verification: VerificationPreviewInfo
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Image(systemName: "checkmark.seal.text.page")
                .font(.largeTitle)
                .foregroundColor(.accentColor)

            Text("Verification Request")
                .font(.largeTitle).bold()
                .multilineTextAlignment(.center)
            
            VStack(alignment: .center, spacing: 16) {
                Text("**\(verification.label ?? "Unknown")** has requested identity details.")
                    .padding()
                List {
                    LabeledContent("Credential", value: verification.documentTypes.joined(separator: "\n"))
                    LabeledContent("Name", value: verification.name)
                    LabeledContent("Purpose", value: verification.purpose)
                }
                
                Spacer()
                Text("If you want to generate the requested identity details, tap **Preview Request Details**.")
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
                    await model.previewVerificationRequest(verification)
                    self.canNavigate.toggle()
                }
            }) {
                ZStack {
                    Image("busy")
                        .rotationEffect(.degrees(model.isProcessing ? 360.0 : 0.0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: model.isProcessing)
                        .opacity(model.isProcessing ? 1 : 0)
                    
                    Text("Preview Identity Details")
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
            AddVerificationClaimsView(preview: verification)
        }
    }
}

//#Preview {
//    AddVerificationRequestView(verification: nil)
//        .environment(Model())
//}
