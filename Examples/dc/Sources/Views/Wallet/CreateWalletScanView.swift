//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI
import CodeScanner

struct CreateWalletScanView: View {
    private let json = """
    {
        "serviceBaseUrl": "https://127.0.0.1:9720/diagency",
        "oauthBaseUrl": "https://127.0.0.1:8436/oauth2"
    }    
    """
    
    @Environment(Model.self) private var model
    @State private var code = String()
    @State private var canNavigate = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 24) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                Text("Scan QR Code")
                    .font(.largeTitle).bold()
                    .multilineTextAlignment(.center)
                
                CodeScannerView(codeTypes: [.qr], showViewfinder: true, simulatedData: json) { result in
                    switch result {
                    case .success(let value):
                        code = value.string
                        canNavigate.toggle()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.50)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            model.createWalletIsPresented = false
                        }
                    }
                }
            }
        }
        .padding()
        .navigationDestination(isPresented: $canNavigate) {
            CreateWalletRegistrationView(json: code)
        }
    }
}
  
#Preview {
    CreateWalletScanView()
        .environment(Model())
}
