//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//
import SwiftUI
import DC

struct CredentialDetailView: View {
    @Environment(Model.self) private var model
    @Environment(\.dismiss) var dismiss
    @State private var isPresentingAlert = false
    
    let credential: Credential
    
    var body: some View {
        List {
            Section(header: Text("General")) {
                LabeledContent("ID", value: credential.id)
                LabeledContent("Format", value: credential.type.format.rawValue)
                LabeledContent("State", value: credential.type.state.rawValue)
                LabeledContent("Role", value: credential.type.role.rawValue)
                LabeledContent("Issuer DID", value: credential.type.issuerDid)
            }
            Section(header: Text("Documents")) {
                ForEach(credential.documentTypes, id: \.self) { type in
                    Label(type, systemImage: "text.document")
                }
            }
            NavigationLink(destination: CredentialTechnicalView(jsonRepresentation: credential.type.jsonRepresentation ?? Data())) {
                Label("Technical", systemImage: "gearshape")
            }
            
            Section {
                
                Button("Delete") {
                    isPresentingAlert = true
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(model.isProcessing)
                .alert(isPresented: $isPresentingAlert) {
                    Alert(
                        title: Text("Are you sure you want to delete credential?"),
                        message: Text("You will have to request the credential again."),
                        primaryButton: .destructive(Text("Delete")) {
                            Task {
                                await model.deleteCredential(credential)
                                self.dismiss()
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                .foregroundColor(.red)
            }
        }
    }
}

#Preview {
//CredentialDetailView()
}
