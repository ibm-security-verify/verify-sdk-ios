//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//
import SwiftUI

struct CreateWalletRegistrationView: View {
    @Environment(Model.self) private var model
    @FocusState private var accountNameIsFocused: Bool
    @State private var accountName = String()
    @State private var username = "user_1"
    @State private var password = "secret"
    
    let json: String
        
    var body: some View {
        @Bindable var model = model

        VStack(alignment: .center, spacing: 24) {
            Image(systemName: "person.circle")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
            Text("Register")
                .font(.largeTitle).bold()
                .multilineTextAlignment(.center)
            Text("Provider a name for the wallet and your username and password to establish a connection.")
                .font(.body)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 8) {
                TextField("Account name", text: $accountName)
                    .textFieldStyle(InputTextFieldStyle())
                    .focused($accountNameIsFocused)
                    .padding()
                
                TextField("Email or username", text: $username)
                    .textFieldStyle(InputTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(InputTextFieldStyle())
                    .padding()
            }
            .onAppear {
                accountNameIsFocused = true
            }
            
            Spacer()
            
            Button(action: {
                Task {
                    await model.register(json, accountName: accountName, username: username, password: password)
                }
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
            .disabled(self.accountName.isEmpty || self.username.isEmpty || self.password.isEmpty)
        }
        .padding()
        .contentMargins(20, for: .scrollContent)
        .interactiveDismissDisabled()
        .navigationDestination(isPresented: $model.canNavigate) {
            CreateWalletSuccessView(accountName: accountName)
        }
        
    }
}

#Preview {
    CreateWalletRegistrationView(json: "hello world")
        .environment(Model())
}
