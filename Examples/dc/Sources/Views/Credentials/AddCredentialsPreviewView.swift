//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI
import DC

struct AddCredentialPreviewView: View {
    @Environment(Model.self) private var model
    @State private var canNavigate = false
    
    let info: CredentialPreviewInfo
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Image(systemName: "person.text.rectangle")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
            Text("Get Started")
                .font(.largeTitle).bold()
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 16) {
                List {
                    LabeledContent("Company", value: info.label ?? "someone")
                    LabeledContent("Offer", value: info.documentTypes.joined(separator: "\n"))
                        .multilineTextAlignment(.trailing)
                }
                Spacer()
                Text("If the information is correct, tap **Continue** to preview the credential.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .background(Color(UIColor.systemBackground))
            .scrollContentBackground(.hidden)
            
            Spacer()
            Button(action: {
                self.canNavigate.toggle()
            }) {
                ZStack {
                    Image("busy")
                        .rotationEffect(.degrees(model.isProcessing ? 360.0 : 0.0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: model.isProcessing)
                        .opacity(model.isProcessing ? 1 : 0)
                    
                    Text("Continue")
                        .opacity(model.isProcessing ? 0 : 1)
                        .frame(maxWidth:.infinity)
                }
            }
            .buttonStyle(.fullWidth)
        }
        .padding()
        .contentMargins(20, for: .scrollContent)
        .interactiveDismissDisabled()
        .navigationDestination(isPresented: $canNavigate) {
            AddCredentialOfferView(info: info)
        }
    }
}

#Preview {
//    AddCredentialPreviewView(json: "abc123")
//        .environment(Model())
}
