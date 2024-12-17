//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI

struct WalletProfileView: View {
    @Environment(Model.self) private var model
     
    var body: some View {
        @Bindable var model = model
        
        VStack {
            if !model.createWalletIsPresented, let wallet = model.wallet {
                List {
                    Section(header: Text("Agent")) {
                        LabeledContent("ID", value: wallet.agent.id)
                        LabeledContent("Name", value: wallet.agent.name)
                        LabeledContent("Host", value: wallet.agent.agentURL.absoluteURL.host(percentEncoded: false)!)
                    }
                }
                .background(Color(UIColor.systemBackground))
                .scrollContentBackground(.hidden)
                .toolbar {
                    ToolbarItem(placement: .destructiveAction) {
                        Button {
                            model.reset()
                        } label: {
                            Text("Reset")
                                .tint(Color.red)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            else {
                ContentUnavailableView("No Wallet Available", systemImage: "person.text.rectangle", description: Text("To get started, you need to create a wallet to hold your credentials and perform verifications."))
                    .toolbar {
                        ToolbarItem {
                            Button("Create Wallet") {
                                model.createWalletIsPresented.toggle()
                            }
                            .sheet(isPresented: $model.createWalletIsPresented) {
                                NavigationStack {
                                    CreateWalletScanView()
                                }
                            }
                        }
                    }
            }
        }
        .navigationTitle("Wallet")
        .interactiveDismissDisabled()
    }
}

#Preview {
    WalletProfileView()
        .environment(Model())
}
