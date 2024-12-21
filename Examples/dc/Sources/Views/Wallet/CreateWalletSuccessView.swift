//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI

struct CreateWalletSuccessView: View {
    @Environment(Model.self) private var model
    
    let accountName: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
                .symbolEffect(.bounce.up.byLayer, options: .nonRepeating)
            Text("Complete!")
                .font(.largeTitle).bold()
                .multilineTextAlignment(.center)
            Text("Your wallet has been created. You can now accept digital credentials and respond to credential verifications.")
                .font(.body)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .center) {
                HStack {
                    Text("Account name:")
                        .fontWeight(.semibold)
                    Text(accountName)
                }
            }
            
            Spacer()
            
            Button("Done") {
                model.createWalletIsPresented.toggle()
            }
            .buttonStyle(.fullWidth)
        }
        .padding()
        .contentMargins(20, for: .scrollContent)
        .interactiveDismissDisabled()
    }
}

#Preview {
    CreateWalletSuccessView(accountName: "Foo")
        .environment(Model())
}
