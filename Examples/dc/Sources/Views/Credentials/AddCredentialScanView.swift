//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI
import CodeScanner
import DC

struct AddCredentialScanView: View {
    // Credential invitation
    private let url = "https://diagency:9720/diagency/a2a/v1/messages/eec19c85-d8e7-4694-8520-19762b0e76f7/invitation?id=951d1e95-20e2-460a-baab-52f65b253535"
    
    @Environment(Model.self) private var model
    @State private var canNavigate = false
    @State private var preview: (any PreviewDescriptor)?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 24) {
                Image(systemName: "qrcode.viewfinder")
                    .font(.largeTitle)
                    .foregroundColor(.accentColor)
                Text("Scan QR Code")
                    .font(.largeTitle).bold()
                    .multilineTextAlignment(.center)
                
                CodeScannerView(codeTypes: [.qr], showViewfinder: true, simulatedData: url) { result in
                    switch result {
                    case .success(let value):
                        Task {
                            if let preview = await model.previewInvitation(value.string) {
                                self.preview = preview
                                canNavigate.toggle()
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.50)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            model.addCredentialIsPresented.toggle()
                        }
                    }
                }
                .navigationDestination(isPresented: $canNavigate) {
                    if let preview = preview as? CredentialPreviewInfo {
                        AddCredentialPreviewView(info: preview)
                    }
                }
            }
        }
        .padding()
    }
}
  
#Preview {
    AddCredentialScanView()
        .environment(Model())
}
