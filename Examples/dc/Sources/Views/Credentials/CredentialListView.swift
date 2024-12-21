//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI
import DC

struct CredentialListView: View {
    @Environment(Model.self) private var model
    
    var body: some View {
        @Bindable var model = model
        
        VStack {
            if let wallet = model.wallet {
                VStack {
                    if wallet.credentials.isEmpty {
                        ContentUnavailableView("No Credentials", systemImage: "person.crop.rectangle.stack", description: Text("Your wallet doesn't have any credentials."))
                    }
                    else if !model.addCredentialIsPresented {
                        NavigationStack {
                            List(wallet.credentials, id: \.type.id) { credential in
                                NavigationLink(destination: CredentialDetailView(credential: credential)) {
                                    credentialPresentation(credential)
                                        .shadow(radius: 4)
                                }
                            }
                            .listRowSpacing(10.0)
                            .listStyle(.plain)
                        }
                        .background(Color(UIColor.systemBackground))
                        .scrollContentBackground(.hidden)
                    }
                }
                .toolbar {
                    ToolbarItem {
                        Button("Add Credential") {
                            model.addCredentialIsPresented.toggle()
                        }
                        .sheet(isPresented: $model.addCredentialIsPresented) {
                            NavigationStack {
                                AddCredentialScanView()
                            }
                        }
                    }
                }
            }
            else {
                ContentUnavailableView("No Wallet Available", systemImage: "person.text.rectangle", description: Text("To get started, you need to create a wallet to hold your credentials and perform verifications."))
            }
        }
        .navigationTitle("Credentials")
    }
    
    
    @ViewBuilder
    /// Obtain the view that will display the credential associated with the document type.
    /// - Parameters:
    ///  - credential: The credential to be previewed
    /// - Returns: The view associated with the document type.
    func credentialPresentation(_ credential: Credential) -> some View {
        if let view = model.credentialPreview(for: credential) {
            view
        }
    }
}

#Preview {
    CredentialListView()
        .environment(Model())
}
