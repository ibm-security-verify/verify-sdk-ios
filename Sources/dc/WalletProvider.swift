//
// Copyright contributors to the IBM Verify Digital Credentials SDK for iOS project
//

import Foundation
import Core
import Authentication

// MARK: Enums

/// A type that indicates when a wallet operation fails.
public enum WalletError: Error, LocalizedError, Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: WalletError, rhs: WalletError) -> Bool {
        return lhs.localizedDescription == rhs.localizedDescription
    }
    
    /// An error that occurs when a JSON value fails to parse as the specified type.
    case failedToParse
    
    /// Invalid JSON format to create an ``MFARegistrationDescriptor``.
    case invalidFormat
       
    /// The initialization fails for some reason (for example if data does not represent valid data for encoding).
    case dataInitializationFailed

    /// A general registration error ocurred.
    case underlyingError(error: Error)
    
    /// Occurs when a proof request fails.
    case verificationFailed(message: String)
}

/// An instance you use to instaniate an ``WalletService`` to perfrom digital credentail operations.
public actor WalletProvider {
    /// The JSON string that initiates the wallet.
    let json: String
    
    /// An object that coordinates a group of related, network data transfer tasks.
    let urlSession: URLSession
    
    /// A Boolean value that indicates whether the authenticator will ignore secure sockets layer certificate challenages.
    ///
    ///  Before invoking ``initiate(with:pushToken:additionalData:)`` this value can be used to alert the user that the certificate connecting the service is self-signed.
    /// - Remark: When `true` the service is using a self-signed certificate.
    let ignoreSSLCertificate: Bool
    
    // Creates the instance with JSON value.
    /// - Parameters:
    ///   - value: The JSON value typically obtained from a QR code.
    ///
    /// ```swift
    /// // Value from QR code scan.
    /// let qrScanResult = "{"serviceBaseUrl": "https://sdk.verifyaccess.ibm.com/diagency","oauthBaseUrl": "https://sdk.verifyaccess.ibm.com/oauth2"}
    ///
    /// // Create an access token.
    /// let oauthProvider = OAuthProvider(clientId: "abc123")
    /// let token = try await oauthProvider.authorize(issuer: URL(string: "https://sdk.verifyaccess.ibm.com/oauth2/token")!, username: "user", password: "password")
    ///
    /// // Create the wallet provider.
    /// let provider = WalletProvider(json: qrScanResult)
    ///
    /// // Instaniate the wallet.
    /// let wallet = try await provider.register(with: "John", clientId: "abc123", token: token, pushToken: "abc123")
    ///
    /// // Get a list of credentials document types.
    /// wallet.credentials.forEach { $0
    ///    print($0.documentTypes)
    /// }
    /// ```
    public init(json value: String, ignoreSSLCertificate: Bool = false) {
        self.json = value
        self.ignoreSSLCertificate = ignoreSSLCertificate
        
        if self.ignoreSSLCertificate {
            // Set the URLSession for certificate pinning.
            self.urlSession = URLSession(configuration: .ephemeral, delegate: SelfSignedCertificateDelegate(), delegateQueue: nil)
        }
        else {
            self.urlSession = URLSession.shared
        }
    }

    /// Registers a new device to connect to an agent for receiving credentials, connection invitation and proof requests.
    /// - Parameters:
    ///   - name: The account name associated with the agent.
    ///   - clientId: The client identifier issued to the client during the OAuth registration process.
    ///   - accessToken: The access token generated by the authorization server.
    ///   - refreshToken: The refresh token, which can be used to obtain new access tokens using the same authorization grant.
    ///   - expiresIn: The lifetime in seconds of the access token. Default is `3600`.
    ///   - pushToken: A token that identifies the device to Apple Push Notification Service (APNS).
    ///
    ///Communicate with Apple Push Notification service (APNs) and receive a unique device token that identifies your app.  Refer to [Registering Your App with APNs](https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns).
    public func register(with name: String, clientId: String, accessToken: String, refreshToken: String? = nil, expiresIn: Int? = 3600, pushToken: String? = nil) async throws -> Wallet {
        // Allocate the default expiresIn value, if required.
        var expiresInValue = 3600
        if let expiresIn {
            expiresInValue = expiresIn
        }
        
        // Construct a TokenInfo.
        let data = """
        {
            "refreshToken": "\(refreshToken ?? "")",
            "accessToken": "\(accessToken)",
            "expiresIn": \(expiresInValue)
        }
        """.data(using: .utf8)!
        
        let token = try JSONDecoder().decode(TokenInfo.self, from: data)
        
        return try await register(with: name, clientId: clientId, token: token, pushToken: pushToken)
    }
    
    /// Registers a new device to connect to an agent for receiving credentials, connection invitation and proof requests.
    /// - Parameters:
    ///   - name: The account name associated with the agent.
    ///   - clientId: The client identifier issued to the client during the OAuth registration process.
    ///   - token: The ``TokenInfo`` generated by the authorization server.
    ///   - pushToken: A token that identifies the device to Apple Push Notification Service (APNS).
    ///
    ///Communicate with Apple Push Notification service (APNs) and receive a unique device token that identifies your app.  Refer to [Registering Your App with APNs](https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns).
    public func register(with name: String, clientId: String, token: TokenInfo, pushToken: String? = nil) async throws -> Wallet {
            
        // Create a JSONDecoder for custom parsing.
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        guard let data = json.data(using: .utf8), let result = try? decoder.decode(WalletInitializationInfo.self, from: data) else {
            throw WalletError.dataInitializationFailed
        }
        
        // Set the base URL's
        let serviceBaseUrl = URL(string: "\(result.serviceBaseUrl)/v1.0/diagency")!
        let oauthBaseUrl = URL(string: "\(result.oauthBaseUrl)/token")!
        let credentialsUrl = URL(string: "\(serviceBaseUrl)/credentials?filter=%7B%22state%22:%22stored%22%7D")!
        
        // Add additional data to obtain the Token.
        var additionalParameters: [String: Any] = [:]
        if let pushToken = pushToken {
            additionalParameters.updateValue(pushToken, forKey: "pushToken")
        }
        
        // Resource for obtaining the agent.
        let agentResource = HTTPResource<AgentInfo>(json: .get, url: serviceBaseUrl.appendingPathComponent("info"), headers: ["Authorization": token.authorizationHeader], decoder: decoder)
        
        // Resource for obtaining connections, this requires a custom parser to only decode the items JSON array.
        let connectionResource = HTTPResource<[ConnectionInfo]>(.get, url: serviceBaseUrl.appendingPathComponent("connections"), headers: ["Authorization": token.authorizationHeader]) { data, response in
            guard let data = data, !data.isEmpty else {
                return .failure(WalletError.dataInitializationFailed)
            }
                
            guard let connections = try? decoder.decode(type: [ConnectionInfo].self, from: data) else {
                return .failure(WalletError.failedToParse)
            }

            return .success(connections)
        }
        
        // Resource for obtaining invitation, this requires a custom parser to only decode the items JSON array.
        let invitationResource = HTTPResource<[InvitationInfo]>(.get, url: serviceBaseUrl.appendingPathComponent("invitations"), headers: ["Authorization": token.authorizationHeader]) { data, response in
            guard let data = data, !data.isEmpty else {
                return .failure(WalletError.dataInitializationFailed)
            }
                
            guard let invitations = try? decoder.decode(type: [InvitationInfo].self, from: data) else {
                return .failure(WalletError.failedToParse)
            }

            return .success(invitations)
        }
        
        // Resource for obtaining credentials, this requires a custom parser to only decode the items JSON array.
        let credentailResource = HTTPResource<[Credential]>(.get, url: credentialsUrl, headers: ["Authorization": token.authorizationHeader]) { data, response in
            guard let data = data, !data.isEmpty else {
                return .failure(WalletError.dataInitializationFailed)
            }
                
            guard let credentails = try? decoder.decode(type: [Credential].self, from: data) else {
                return .failure(WalletError.failedToParse)
            }

            // Map the collection from a Credential to CredentialDescriptpr.
            return .success(credentails)
        }
        
        do {
            async let agent = try self.urlSession.dataTask(for: agentResource)
            async let connections = try self.urlSession.dataTask(for: connectionResource)
            async let invitations = try self.urlSession.dataTask(for: invitationResource)
            async let credentails = try self.urlSession.dataTask(for: credentailResource)
            
            return await Wallet(refreshUri: oauthBaseUrl,
                                baseUri: serviceBaseUrl,
                                clientId: clientId,
                                token: token,
                                agent: try agent,
                                connections: try connections,
                                invitations: try invitations,
                                credentials: try credentails)
        }
        catch let error {
            throw error
        }
    }
}

extension WalletProvider {
    /// The structure to initialize a wallet.
    private struct WalletInitializationInfo: Decodable {
        /// The base URL to the agent services
        let serviceBaseUrl: URL
        
        /// The endpoint to support OAuth token operations.
        let oauthBaseUrl: URL
    }
}