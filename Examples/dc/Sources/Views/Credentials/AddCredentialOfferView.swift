//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI
import DC

struct AddCredentialOfferView: View {
    @Environment(Model.self) private var model
    @State private var canNavigate = false
    
    let info: CredentialPreviewInfo
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            if model.preview(using: info) == nil {
                ContentUnavailableView("Unknown Credential", systemImage: "exclamationmark.triangle", description: Text("The credential was unable to be presented."))
            }
            else {
                Image(systemName: "person.text.rectangle")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                Text("If This You?")
                    .font(.largeTitle).bold()
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 16) {
                    credentialPresentation(info)
                    
                    Spacer()
                    Text("**\(info.label ?? "Unknown")** issued these identity details about you. If the information looks correct, tap **Add to Wallet**.")
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
                        await model.addCredential(info)
                        self.canNavigate.toggle()
                    }
                }) {
                    ZStack {
                        Image("busy")
                            .rotationEffect(.degrees(model.isProcessing ? 360.0 : 0.0))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: model.isProcessing)
                            .opacity(model.isProcessing ? 1 : 0)
                        
                        Text("Add to wallet")
                            .opacity(model.isProcessing ? 0 : 1)
                            .frame(maxWidth:.infinity)
                    }
                }
                .buttonStyle(.fullWidth)
                
                Button("Cancel") {
                    model.addCredentialIsPresented.toggle()
                }
                .tint(.blue)
            }
        }
        .padding()
        .contentMargins(20, for: .scrollContent)
        .interactiveDismissDisabled()
        .navigationDestination(isPresented: $canNavigate) {
            AddCredentialSuccessView(credentialName: model.matchedPreviewName(using: info))
        }
    }
    
    @ViewBuilder
    /// Obtain the view that will display the credential associated with the document type.
    /// - Parameters:
    ///  - credential: The credential to be previewed
    /// - Returns: The view associated with the document type.
    func credentialPresentation(_ credential: CredentialPreviewInfo) -> some View {
        if let view = model.preview(using: info) {
            view
        }
    }
}

//#Preview {
//    AddCredentialOfferView(credential: nil)
//        .environment(Model())
//}
