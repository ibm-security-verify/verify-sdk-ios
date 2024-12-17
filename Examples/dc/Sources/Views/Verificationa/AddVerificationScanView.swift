//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI
import CodeScanner
import DC

struct AddVerificationScanView: View {
    // Verifiction invitation
    private let url = "https://diagency:9720/diagency/a2a/v1/messages/76db8420-9867-4344-9aa2-3472f37936fd/invitation?id=d02a10a5-1d22-4ebd-8fb7-839e10fbbb38"
    
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
                            model.proofRequestIsPresented.toggle()
                        }
                    }
                }
                .navigationDestination(isPresented: $canNavigate) {
                    if let preview = preview as? VerificationPreviewInfo {
                        AddVerificationPreviewView(verification: preview)
                    }
                }
            }
        }
        .padding()
    }
}
  
#Preview {
    AddVerificationScanView()
        .environment(Model())
}
