//
// Copyright contributors to the IBM Security Verify MFA Sample App for iOS project
//

import Foundation
import MFA
import Core
import CryptoKit
import SwiftUI

@MainActor
class RegistrationViewModel: ObservableObject {
    private var dataManager: DataManager = DataManager()
    
    @Published var accountName: String = String()
    @Published var errorMessage: String = String()
    @Published var navigate: Bool = false
    @Published var isPresentingErrorAlert: Bool = false
    
    // Validates the QR code.
    func validateCode(code: String) async {
        let controller = MFARegistrationController(json: code)
        
        do {
            let provider = try await controller.initiate(with: self.accountName)
                    
            while let factor = await provider.nextEnrollment() {
                print("Enrolling \(factor)")
                try await provider.enroll()
            }
           
            // Generate the authenticator
            let authenticator = try await provider.finalize()
            await saveAuthenticator(authenticator: authenticator)
            
            navigate = true
        }
        catch let error {
            print(error.localizedDescription)
            errorMessage = error.localizedDescription
            isPresentingErrorAlert = true
        }
    }
    
    func saveAuthenticator(authenticator: (any MFAAuthenticatorDescriptor)) async {
        do {
            try dataManager.save(authenticator: authenticator)
        }
        catch let error {
            errorMessage = error.localizedDescription
            isPresentingErrorAlert = true
        }
    }
}
