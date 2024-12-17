//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import Foundation
import Core
import DC
import SwiftUICore
import Authentication

/// A model representing all of the data the app needs to display in its interface.
@Observable final class Model {
    /// Instance of the DataManager to handle persistance.
    private let dataManager = DataManager()
    
    /// The instance of the Wallet.
    var wallet: Wallet?
    
    /// Holds the list of verification for the wallet
    var verifications: [VerificationInfo] = []
    
    /// Holds the generated verification prior to sharing.
    var verificationGenerated: VerificationInfo?
    
    /// Client Id for performing an ROPC authentication flow.
    let clientId = "onpremise_vcholders"
    
    /// The available verifications to preview.
    let verificationPreviews: [String: any View] = ["AustralianBorn-1733101773.9349709": ResidentProofRequestView(),
                                                 "au.gov.servicesaustralia.medicare.card": MedicareProofRequestView(),
                                                 "Whs71TiiEmFuwmMKsW4c4Y:3:CL:22:TAG1": EmployeeProofRequestView()]
    
    /// The available credentials to preview.
    let credentialPreviews: [String: any View] = ["PermanentResidentCard": ResidentCredentialOfferView(),
                                                 "au.gov.servicesaustralia.medicare.card": MedicareCredentialOfferView(),
                                                 "Whs71TiiEmFuwmMKsW4c4Y:3:CL:22:TAG1": EmployeeCredentialOfferView()]
    
    /// The available credentials to preview.
    let availableCredentials: [String: any View] = ["PermanentResidentCard": ResidentCredentialCardView(),
                                                    "au.gov.servicesaustralia.medicare.card": MedicareCredentialCardView(),
                                                    "Whs71TiiEmFuwmMKsW4c4Y:3:CL:22:TAG1": EmployeeCredentialCardView()]
    
    /// Initializes a new instance of a Model.
    init() {
        // Attempt to initialize the wallet if previously saved.
        guard let wallet = dataManager.load() else {
            return
        }
        
        self.wallet = wallet
    }
    
    /// Resets the wallet.
    func reset() {
        defer {
            self.wallet = nil
        }
        
        dataManager.reset()
    }
    
    // MARK: Previews
    /// The type of preview to display
    enum PreviewType: String {
        /// A credential preview.
        case credentials
        
        /// A verification preview.
        case verifications
    }
    
    /// Checks if the credential document types for presentation matches any of the available known credentials for verifying a credential.
    /// - Parameters:
    ///  - type: The type of preview.
    ///  - info: The ``PreviewDescriptor`` to be previewed.
    /// - Returns: The view associated with the document type.
    func preview(for type: PreviewType = .credentials, using info: any PreviewDescriptor) -> AnyView?  {
        let keys = [String](type == .credentials ? credentialPreviews.keys : verificationPreviews.keys)
        
        // Get the known key that references a credential type.
        guard let key = keys.first(where: { info.documentTypes.contains($0) }) else {
            return nil
        }
        
        // Retrieve the instance of the associated document type and assign the JSON for the view to parse and present.
        if let view = (type == .credentials ? credentialPreviews : verificationPreviews)[key], var descriptor = view as? (any ViewDescriptor), let jsonRepresentation = info.jsonRepresentation {
            descriptor.jsonRepresentation = jsonRepresentation
            return AnyView(descriptor)
        }
        
        return nil
    }
    
    /// Checks if the credential document types for presentation matches any of the available known credentials.
    /// - Parameters:
    ///  - credential: The credential to be previewed
    /// - Returns: The view associated with the document type.
    func credentialPreview(for credential: Credential) -> AnyView?  {
        let keys = [String](availableCredentials.keys)
        
        // Get the known key that references a credential type.
        guard let key = keys.first(where: { credential.documentTypes.contains($0) }) else {
            return nil
        }
        
        // Retrieve the instance of the associated document type and assign the JSON for the view to parse and present.
        if let view = availableCredentials[key], var descriptor = view as? (any ViewDescriptor), let jsonRepresentation = credential.type.jsonRepresentation {
            descriptor.jsonRepresentation = jsonRepresentation
            return AnyView(descriptor)
        }
        
        return nil
    }
    
    /// Checks if the document types for presentation matches any of the available known credential or verifications.
    /// - Parameters:
    ///  - type: The type of preview.
    ///  - info: The ``PreviewDescriptor`` to be previewed.
    /// - Returns: The name of the matched credential.
    func matchedPreviewName(for type: PreviewType = .credentials, using info: any PreviewDescriptor) -> String {
        let keys = [String](type == .credentials ? credentialPreviews.keys : verificationPreviews.keys)
        
        // Get the known key that references a document type.
        guard let key = keys.first(where: { info.documentTypes.contains($0) }) else {
            return ""
        }
        
        return key
    }
    
    // MARK: Navigation & Operation Publishers
    
    /// A flag to manage the state of the create wallet flow.
    var createWalletIsPresented = false
    
    /// A flag to manage the state of the add credential flow.
    var addCredentialIsPresented = false
    
    /// A fliag to manage the state of a proof request verificxation flow.
    var proofRequestIsPresented = false
    
    /// Flag to indicate if a wallet operation can proceed to a next View.
    var canNavigate = false
    
    /// Flag to indicate a wallet operation is processing an operation.
    ///
    /// A View can use this flag to show or hide visual cues to the end user.
    var isProcessing = false
}

// MARK: Wallet Creation
extension Model {
    /// Regsters a new wallet against a user credential.
    /// - Parameters:
    ///   - json: The string value represented in a QR code.
    ///   - accountName: The name of the account or wallet.
    ///   - username: The username to authenticate to a token endpoint in the `json` string.
    ///   - password: The password for the `username`.
    func register(_ json: String, accountName: String, username: String, password: String) async {
        defer {
            self.isProcessing.toggle()
        }

        self.isProcessing.toggle()

        let provider = WalletProvider(json: json, ignoreSSLCertificate: true)
        
        // Obtain an authentication token.
        let oauthProvider = OAuthProvider(clientId: clientId, certificateTrust: SelfSignedCertificateDelegate())
        do {

            let token = try await oauthProvider.authorize(issuer: URL(string: "https://127.0.0.1:8436/oauth2/token")! , username: username, password: password)
            let wallet = try await provider.register(with: accountName, clientId: clientId, token: token)
            dataManager.save(wallet)
            
            self.wallet = wallet
            self.canNavigate.toggle()
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
}

// MARK: Scanning Operations
extension Model {
    internal struct WalletScanInfo: Decodable {
        /// The type of initialization.
        let type: String
        
        /// The information to support the wallet initialization.
        let data: Data
        
        struct Data: Decodable {
            /// The name of the agent.
            let name: String
            
            /// The unique identifier of the agent.
            let id: String
            
            /// The base URL to the agent.
            let url: URL
            
            /// The client identifier of the OAuth provider.
            let clientId: String
            
            /// The endpoint to support token refresh.
            let tokenEndpoint: URL
        }
    }
}

// MARK: Verification Operations

extension Model {
    /// Gets a list oif verifications for the user.
    func listVerifications() async {
        defer {
            self.isProcessing.toggle()
        }
        
        guard let wallet else {
            return
        }
        
        self.isProcessing.toggle()
        
        let service = WalletService(token: wallet.token.accessToken,
                                        refreshUri: wallet.refreshUri,
                                        baseUri: wallet.baseUri,
                                        clientId: wallet.clientId,
                                        certificateTrust: SelfSignedCertificateDelegate())
        service.delegate = self
        
        // If a token refresh is required, invoke and update token.
        if wallet.token.shouldRefresh, let refreshToken = wallet.token.refreshToken, let token = try? await service.refreshToken(using: refreshToken) {
            self.wallet?.token = token
            dataManager.save(self.wallet)
        }
        
        do {
            self.verifications.removeAll()
            self.verifications = try await service.retrieveProofRequests()
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func verifyCredential(_ verification: VerificationPreviewInfo) async {
        defer {
            self.isProcessing.toggle()
        }
        
        guard let wallet else {
            return
        }
        
        let service = WalletService(token: wallet.token.accessToken,
                                        refreshUri: wallet.refreshUri,
                                        baseUri: wallet.baseUri,
                                        clientId: wallet.clientId,
                                        certificateTrust: SelfSignedCertificateDelegate())
        service.delegate = self
        
        // If a token refresh is required, invoke and update token.
        if wallet.token.shouldRefresh, let refreshToken = wallet.token.refreshToken, let token = try? await service.refreshToken(using: refreshToken) {
            self.wallet?.token = token
        }
        
        do {
            self.isProcessing.toggle()
            try await service.processProofRequest(with: verification, action: .share)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func previewVerificationRequest(_ verification: VerificationPreviewInfo) async {
        defer {
            self.isProcessing.toggle()
        }
        
        guard let wallet else {
            return
        }
        
        let service = WalletService(token: wallet.token.accessToken,
                                        refreshUri: wallet.refreshUri,
                                        baseUri: wallet.baseUri,
                                        clientId: wallet.clientId,
                                        certificateTrust: SelfSignedCertificateDelegate())
        service.delegate = self
        
        // If a token refresh is required, invoke and update token.
        if wallet.token.shouldRefresh, let refreshToken = wallet.token.refreshToken, let token = try? await service.refreshToken(using: refreshToken) {
            self.wallet?.token = token
        }
        
        do {
            self.isProcessing.toggle()
            try await service.processProofRequest(with: verification)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
}

// MARK: Invitation Operations

extension Model {
    /// Attempts to preview the credential invitation.
    /// - Parameters:
    ///   - json: The string value represented in a QR code.
    /// - Returns: An instance of `InvitationPreviewInfo` otherwise `nil`
    func previewInvitation(_ url: String) async -> (any PreviewDescriptor)? {
        // Make sure we can create the URL.
        guard let url = URL(string: url) else {
            return nil
        }
        
        guard let wallet else {
            return nil
        }
        
        let service = WalletService(token: wallet.token.accessToken,
                                    refreshUri: wallet.refreshUri,
                                    baseUri: wallet.baseUri,
                                    clientId: wallet.clientId,
                                    certificateTrust: SelfSignedCertificateDelegate())
        
        // If a token refresh is required, invoke and update token.
        if wallet.token.shouldRefresh, let refreshToken = wallet.token.refreshToken, let token = try? await service.refreshToken(using: refreshToken) {
            self.wallet?.token = token
            dataManager.save(self.wallet)
        }
        
        guard let preview = try? await service.previewInvitation(using: url) else {
            return nil
        }
        
        return preview
    }
}

// MARK: Credential Operations

extension Model {
    func addCredential(_ credential: CredentialPreviewInfo) async {
        defer {
            self.isProcessing.toggle()
        }
        
        guard let wallet else {
            return
        }
        
        let service = WalletService(token: wallet.token.accessToken,
                                        refreshUri: wallet.refreshUri,
                                        baseUri: wallet.baseUri,
                                        clientId: wallet.clientId,
                                        certificateTrust: SelfSignedCertificateDelegate())
        service.delegate = self
        
        // If a token refresh is required, invoke and update token.
        if wallet.token.shouldRefresh, let refreshToken = wallet.token.refreshToken, let token = try? await service.refreshToken(using: refreshToken) {
            self.wallet?.token = token
        }
        
        do {
            self.isProcessing.toggle()
            try await service.processCredential(with: credential)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func deleteCredential(_ credential: Credential) async {
        defer {
            self.isProcessing.toggle()
        }
        
        guard let wallet else {
            return
        }
        
        let service = WalletService(token: wallet.token.accessToken,
                                        refreshUri: wallet.refreshUri,
                                        baseUri: wallet.baseUri,
                                        clientId: wallet.clientId,
                                        certificateTrust: SelfSignedCertificateDelegate())
        
        do {
            self.isProcessing.toggle()
            print("Deleting credential: \(credential.id)")
            try await service.deleteCredential(with: credential.id)
            
            self.wallet?.credentials.removeAll(where: { $0.id == credential.id })
            dataManager.save(self.wallet)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
}

extension Model: WalletServiceDelegate {
    func walletService(service: WalletService, didAcceptCredential credential: Credential) {
        self.wallet?.credentials.append(credential)
        dataManager.save(self.wallet)
        
        self.canNavigate.toggle()
    }
    
    func walletService(service: WalletService, didVerifyCredential verification: VerificationInfo) {
        self.verifications.append(verification)
        self.canNavigate.toggle()
    }
    
    func walletService(service: WalletService, didGenerateProof verification: VerificationInfo) {
        self.verificationGenerated = verification
        self.canNavigate.toggle()
    }
}
