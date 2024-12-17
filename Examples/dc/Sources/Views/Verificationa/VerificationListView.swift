// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI
import DC

struct VerificationListView: View {
    @Environment(Model.self) private var model
    
    var body: some View {
        @Bindable var model = model
        
        VStack {
            if let wallet = model.wallet {
                VStack {
                    if wallet.credentials.isEmpty {
                        ContentUnavailableView("No Credentials", systemImage: "person.crop.rectangle.stack", description: Text("Your wallet doesn't have any credentials."))
                    }
                    else if model.verifications.isEmpty {
                        ContentUnavailableView("No Verifications", systemImage: "checkmark.seal.text.page", description: Text("No verifications have been requested for your credentials."))
                    }
                    else if !model.proofRequestIsPresented {
                        NavigationStack {
                            List(model.verifications) { verification in
                                NavigationLink(destination: VerificationDetailView(info: verification)) {
                                    VerificationItemView(info: verification)
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
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            Task {
                                await model.listVerifications()
                            }
                        }) {
                            Text("Refresh")
                                .disabled(model.isProcessing)
                        }
                    }
                    ToolbarItem {
                        Button("Verify Credential") {
                            model.proofRequestIsPresented.toggle()
                        }
                        .sheet(isPresented: $model.proofRequestIsPresented) {
                            NavigationStack {
                                AddVerificationScanView()
                            }
                        }
                    }
                }
            }
            else {
                ContentUnavailableView("No Wallet Available", systemImage: "person.text.rectangle", description: Text("To get started, you need to create a wallet to hold your credentials and perform verifications."))
            }
        }
        .navigationTitle("Verifications")
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
    VerificationListView()
        .environment(Model())
}
