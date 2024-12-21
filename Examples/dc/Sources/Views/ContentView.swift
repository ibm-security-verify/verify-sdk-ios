//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI
import CodeScanner

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                WalletProfileView()
            }
            .tabItem {
                Label("Wallet", systemImage: "person.text.rectangle")
            }
            
            NavigationStack {
                CredentialListView()
            }
            .tabItem {
                Label("Credentials", systemImage: "person.crop.rectangle.stack")
            }
            
            NavigationStack {
                VerificationListView()
            }
            .tabItem {
                Label("Verifications", systemImage: "checkmark.seal.text.page")
            }
        }
    }
}

#Preview {
    ContentView()
}
