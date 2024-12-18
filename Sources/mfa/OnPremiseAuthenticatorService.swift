//
// Copyright contributors to the IBM Security Verify MFA SDK for iOS project
//

import Foundation
import Authentication
import Core
import SwiftUI

/// The `OnPremiseAuthenticatorService` enables authenticators to perform transaction, login and token refresh operations.
public actor OnPremiseAuthenticatorService: MFAServiceDescriptor {
    public private(set) var accessToken: String
    public private(set) var currentPendingTransaction: PendingTransactionInfo?
    
    nonisolated public let refreshUri: URL
    nonisolated public let transactionUri: URL
    
    /// The unique identifier between the service and the client app.
    private let clientId: String
    
    /// A unique identifier to link a mobile application to the on-premise service.
    private let authenticatorId: String
    
    /// An object that coordinates a group of related, network data transfer tasks.
    private let urlSession: URLSession
    
    /// Creates the service with the access token and related endpoint URI's.
    /// - Parameters:
    ///   - accessToken: The access token generated by the authorization server.
    ///   - refreshUri: The location of the endpoint to refresh the OAuth token for the authenticator.
    ///   - transactionUri: The location of the endpoint to perform transaction validation.
    ///   - clientId: The unique identifier between the service and the client app.
    ///   - authenticatorId: An identifier generated during registration to uniquely identify the authenticator.
    ///   - certificateTrust: A delegate to handle session-level certificate pinning.
    public init(with accessToken: String, refreshUri: URL, transactionUri: URL, clientId: String, authenticatorId: String, certificateTrust: URLSessionDelegate? = nil) {
        self.accessToken = accessToken
        self.refreshUri = refreshUri
        self.transactionUri = transactionUri
        self.clientId = clientId
        self.authenticatorId = authenticatorId
        
        if let certificateTrust = certificateTrust {
            // Set the URLSession for certificate pinning.
            self.urlSession = URLSession(configuration: .default, delegate: certificateTrust, delegateQueue: nil)
        }
        else {
            self.urlSession = URLSession.shared
        }
    }
    
    /// Refresh the OAuth token associated with the registered authenticator.
    /// - Parameters:
    ///   - refreshToken: The refresh token of the existing authenticator registration.
    ///   - accountName: The account name associated with the service.
    ///   - pushToken: A token that identifies the device to Apple Push Notification Service (APNS).
    ///   - additionalData: (Optional) A collection of options associated with the service.
    /// - Returns: A new `TokenInfo` for the authenticator.
    ///
    /// Communicate with Apple Push Notification service (APNs) and receive a unique device token that identifies your app.  Refer to [Registering Your App with APNs](https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns).
    public func refreshToken(using refreshToken: String, accountName: String? = nil, pushToken: String? = nil, additionalData: [String: Any]? = nil) async throws -> TokenInfo {
        var attributes = MFAAttributeInfo.dictionary(snakeCaseKey: true)
        
        if let accountName = accountName {
            attributes["accountName"] = accountName
        }
        
        if let pushToken = pushToken {
            attributes["pushToken"] = pushToken
        }

        attributes["tenant_id"] = self.authenticatorId
        
        // If there is additional data, merge with the parameters retaining existing values and only adding 10 additional paramterers
        if let additionalData = additionalData {
            var index = 1
            additionalData.forEach {
                if attributes.index(forKey: $0.key) == nil && index <= 10 {
                    attributes.updateValue($0.value, forKey: $0.key)
                    index += 1
                }
            }
        }
        
       // Get a new OAuth token from refresh and update device details.
       let oauthProvider = OAuthProvider(clientId: clientId, additionalParameters: attributes)
       let result = try await oauthProvider.refresh(issuer: self.refreshUri, refreshToken: refreshToken)
            
       // Update the internal accessToken and return
       self.accessToken = result.accessToken
            
       return result
    }
    
    /// Retrieve the next transaction that is associated with an authenticator registration.
    ///
    /// When a `transactionID` is supplied, information relating to that transaction identifier is returned while in a PENDING state.  Otherwise the next transaction is returned.
    /// - Parameters:
    ///   - transactionID: The transaction verification identifier.
    /// - Returns: A `NextTransactionInfo` representing the transaction and a count of the number of pending transactions.
    public func nextTransaction(with transactionID: String? = nil) async throws -> NextTransactionInfo {
        // Set the decoding behaviour.
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8061FormatterBehavior)
        
        // Create the request headers.
        let headers = ["Authorization": "Bearer \(self.accessToken)"]
        let resource = HTTPResource<TransactionResult>(json: .get, url: transactionUri, accept: .json, headers: headers, decoder: decoder)
        
        // Perfom the request to query for pending transactions.
        guard let transactionResult = try? await self.urlSession.dataTask(for: resource) else {
            throw MFAServiceError.invalidDataResponse
        }
        
        // Check if there were any transactions in the payload.
        if transactionResult.transactions.count == 0 {
            return NextTransactionInfo(current: nil, countOfPendingTransactions: transactionResult.transactions.count)
        }
        
        // Process the transactions, which involves making another request to get the verification challenge data.
        guard let pendingTransaction = try? await createPendingTransaction(with: transactionResult, transactionId: transactionID) else {
            throw MFAServiceError.unableToCreateTransaction
        }
        
        self.currentPendingTransaction = pendingTransaction
        
        return NextTransactionInfo(current: pendingTransaction, countOfPendingTransactions: transactionResult.transactions.count)
    }
    
    public func completeTransaction(action userAction: UserAction = .verify, signedData: String) async throws {
        guard let pendingTransaction = currentPendingTransaction else {
            throw MFAServiceError.invalidPendingTransaction
        }
        
        defer {
            // Clear the current pending transaction
            self.currentPendingTransaction = nil
        }
        
        let data: [String: Any] = ["signedChallenge": userAction == .verify ? signedData : ""]
        
        // Covert body dictionary to Data.
        let body = try? JSONSerialization.data(withJSONObject: data, options: [])
        
        // Create the request headers.
        let headers = ["Authorization": "Bearer \(self.accessToken)"]
        let resource = HTTPResource<Void>(.put, url: pendingTransaction.postbackUri, accept: .json, contentType: .json, body: body, headers: headers)
        
        // Perfom the request.
        do {
           return try await self.urlSession.dataTask(for: resource)
        }
        catch let error {
            // If the request is a user deny, no error should be returned.
            if userAction == .deny {
                return
            }
            else {
                throw error
            }
        }
    }
    
    /// Remove the authenticator.
    ///
    /// The `identifer` is stored within the `OnPremiseAuthenticator.token` and is set by IBM Security Verify Access mapping rules.
    ///
    /// See [AuthenticationPostTokenGeneration](https://www.ibm.com/docs/en/sva/10.0.1?topic=rules-mmfa-mapping-rule-methods)
    ///
    /// ```swift
    /// if let identifier = authenticator.token.additionalData["authenticator_id"] {
    ///   let service = OnPremiseAuthenticatorService(with: authenticator.token.accessToken,
    ///                             refreshUri: authenticator.refreshUri,
    ///                             transactionUri: authenticator.transactionUri,
    ///                             clientId: authenticator.clientId,
    ///                             authenticatorId: authenticator.id)
    ///
    ///  // Attempt to remove the registered authenticator.
    ///  try await service.remove(identifier)
    /// }
    /// ```
    public func remove() async throws {
        // Create the parameters for the request body.
        let data: [String: Any] = ["schemas": ["urn:ietf:params:scim:api:messages:2.0:PatchOp"],
                                   "Operations": [
                                       ["op": "remove",
                                        "path": "urn:ietf:params:scim:schemas:extension:isam:1.0:MMFA:Authenticator:authenticators[id eq \(self.authenticatorId)]"],
                                   ]]
        
        // Covert body dictionary to Data.
        let body = try JSONSerialization.data(withJSONObject: data, options: [])
        
        // Create the request headers.
        let headers = ["Authorization": "Bearer \(self.accessToken)"]
        
        // Use the transactionUri to derived the unregister location.
        var componentsUri = URLComponents(url: transactionUri, resolvingAgainstBaseURL: false)!

        // Update the query string to reduce the response body returned.
        componentsUri.query = "attributes=urn:ietf:params:scim:schemas:extension:isam:1.0:MMFA:Authenticator:authenticators"

        let url = componentsUri.url!

        // Execute the request
        let resource = HTTPResource<Void>(.patch, url: url, accept: .json, contentType: .json, body: body, headers: headers)
        
        // Perfom the request.
        return try await self.urlSession.dataTask(for: resource)
    }
}

extension OnPremiseAuthenticatorService {
    // MARK: Internal transaction structures
    
    /// Describes the result of parsing a pending transction from on-premise instances into transaction and transaction attribute data.
    internal struct TransactionResult: Decodable {
        var transactions: [TransactionInfo] = []
        var attributes: [AttributeInfo] = []

        // MARK: Internal enum

        /// The root level JSON structure for decoding.
        private enum CodingKeys: String, CodingKey {
            case transaction = "urn:ietf:params:scim:schemas:extension:isam:1.0:MMFA:Transaction" // Root JSON from on-premise transaction
        }

        /// The nested root decoding structure based off `CodingKeys`.  Used for on-premise transaction and attribute parsing.
        private enum TransactionCodingKeys: String, CodingKey {
            case transactions = "transactionsPending"
            case attributes = "attributesPending"
        }

        // MARK: Internal structs

        struct AttributeInfo: Codable {
            let dataType: String
            let values: [String]
            let uri: String
            let transactionId: String
        }

        struct TransactionInfo: Codable {
            let creationTime: Date
            let requestUrl: URL
            let transactionId: String
            let authnPolicyUri: String

            /// The nested pending transactions decoding structure based off `OnPremisePendingCodingKeys`.  Used for on-premise transaction parsing.
            private enum CodingKeys: String, CodingKey {
                case creationTime
                case requestUrl
                case transactionId
                case authnPolicyUri = "authnPolicyURI"
            }
        }

        // MARK: Initializeras

        /// Creates a new instance by decoding from the given decoder
        /// - parameter decoder: The decoder to read data from.
        public init(from decoder: Decoder) throws {
            // Root keys
            let rootContainer = try decoder.container(keyedBy: CodingKeys.self)

            // Check if the on-premise root container is present.
            if rootContainer.contains(.transaction) {
                let transactionContainer = try rootContainer.nestedContainer(keyedBy: TransactionCodingKeys.self, forKey: .transaction)
                self.attributes = try transactionContainer.decode([AttributeInfo].self, forKey: .attributes)
                self.transactions = try transactionContainer.decode([TransactionInfo].self, forKey: .transactions)

                // Sort if there are more than one transaction
                if (self.transactions.count) > 1 {
                    self.transactions = self.transactions.sorted(by: { $0.creationTime.compare($1.creationTime) == .orderedDescending })
                }
            }
        }
    }
    
    /// The verification information to determine how the transaction challenge can be processed.
    private struct VerificationInfo: Decodable {
        let mechanism: String
        let location: String
        let type: String
        var serverChallenge: String
        let keyHandles: [String]
    }
    
    /// Creates a `PendingTransactionInfo` based on the parsed transaction and attribute data.
    /// - Parameters:
    ///   - result: The `TransactionResult` containing the parsed data.
    ///   - transactionID: The identifier of the transaction.
    /// - Remark: The `TransactionResult.transactions` have been sorted by `creationDate`.
    private func createPendingTransaction(with result: TransactionResult, transactionId: String? = nil) async throws -> PendingTransactionInfo {
        // Optional variable to hold the transaction. By default, we'll store the first transaction encountered but reassign if we match the authenticatorId and/or transactionId.
        var transactionInfoResult = result.transactions.first(where: { $0.transactionId == transactionId }) ?? result.transactions.first

        // 1. Get a list of attributesPending that contain mmfa:request:authenticator:id.
        let identifiers = result.attributes.filter({ $0.uri == "mmfa:request:authenticator:id" })
        
        // 2. A user may have more than one registered authenticator, get the [attributePending] for the authenticator that will verify the transaction.
        if let identifier = identifiers.first(where: { $0.values.contains(authenticatorId) }) {
            // If a transactionId was passed in as a parameter, get that one, otherwise get the first transaction for the authenticator.
            if let transactionId = transactionId {
                transactionInfoResult = result.transactions.first(where: { $0.transactionId == transactionId })
            }
            else {
                transactionInfoResult = result.transactions.first(where: { $0.transactionId == identifier.transactionId })
            }
        }
        
        // 3. Make sure a transaction is resolved.
        guard let transactionInfo = transactionInfoResult else {
            throw MFAServiceError.unableToCreateTransaction
        }
        
        // 4. Get the verification challenage information associated with the transaction. If this doesn't exist we end here.
        let headers = ["Authorization": "Bearer \(self.accessToken)"]
        let resource = HTTPResource<VerificationInfo>(json: .post, url: transactionInfo.requestUrl, accept: .json, headers: headers)
        
        guard let verificationInfo = try? await self.urlSession.dataTask(for: resource) else {
            throw MFAServiceError.invalidDataResponse   // An error here typically is due to missing serverChallenge attribute introduced in ISAM 9.0.6.
        }
        
        // 5. Check if the transaction attributes contain signing information.
        var dataToSign = verificationInfo.serverChallenge
        
        if let signingInfo = result.attributes.first(where: { $0.uri == "mmfa:request:signing:attributes" }), let value = signingInfo.values.first {
            dataToSign = value
        }
        
        // 5. Re-create the FactorId from the keyHandle. Refer to the enroll method where [keyHandles] is a UUID.FactorType
        guard let keyHandle = verificationInfo.keyHandles.first, let id = keyHandle.components(separatedBy: ".").first, let factorId = UUID(uuidString: id) else {
            throw MFAServiceError.general(message: "Unknown key handle to identify factor.")
        }
        
        // 6. Match the message and extras in attributesPending associated to the transactionId.
        let attributeInfo = result.attributes.filter({ $0.transactionId == transactionInfo.transactionId && ($0.uri == "mmfa:request:context:message" || $0.uri == "mmfa:request:extras") })
        
        // 7. Use the localized message as default if the context message doesn't exist.
        var verificationMessage = NSLocalizedString("PendingRequestMessageDefault", bundle: Bundle.module, comment: "")
        if let messageAttribute = attributeInfo.first(where: { $0.uri == "mmfa:request:context:message" }), let message = messageAttribute.values.first {
            verificationMessage = message
        }

        // 8. Normalise the postbackUri.
        let postbackUri = createPostbackUrl(using: transactionInfo.requestUrl, path: verificationInfo.location)
        
        // 9. Construct the "extra" info into additional data associated with the transaction.
        let additionalData = createAdditionalData(with: attributeInfo)

        // 10. Construct the pending transaction taking data from the transaction, attribute and authentication info.
        let result = PendingTransactionInfo(id: transactionInfo.transactionId,
                                            message: verificationMessage,
                                            postbackUri: postbackUri,
                                            factorID: factorId,
                                            factorType: verificationInfo.type,
                                            dataToSign: dataToSign,
                                            timeStamp: transactionInfo.creationTime,
                                            additionalData: additionalData)

        return result
    }
    
    /// Creates ``URL`` for a transaction verification to postback to.
    /// - parameter url: An instance of the `URL` object.
    /// - parameter path: The path to append to the URL.
    /// - returns: The unwrapped `URL`.
    private func createPostbackUrl(using url: URL, path: String) -> URL {
        var component = URLComponents()
        component.scheme = url.scheme
        component.host = url.host
        component.port = url.port
        component.path = path

        if let value = component.url?.absoluteString.removingPercentEncoding {
            return URL(string: value)!
        }
        return component.url!
    }
    
    /// Creates a dictionary of available transaction attributes from the `TransactionResult`.
    /// - parameter attributes: An array of `TransactionResult.AttributeInfo`.
    /// - returns: An array of `TransactionAttribute` and corresponding value.
    private func createAdditionalData(with attributes: [TransactionResult.AttributeInfo]) -> [TransactionAttribute: String] {
        var result: [TransactionAttribute: String] = [:]

        // Check if the extras exist.
        if let item = attributes.first(where: { $0.uri == "mmfa:request:extras" }) {
            do {
                try? item.values.forEach { json in
                    let value = json.data(using: String.Encoding.utf8)!
                    var data = try JSONSerialization.jsonObject(with: value, options: []) as! [String: Any]

                    // Add the type to the result, then remove from dictionary.
                    if let type = data["type"] as? String {
                        result.updateValue(type, forKey: .type)
                        data.removeValue(forKey: "type")
                    }

                    // Add the IP address to the result, then remove from dictionary.
                    if let ipAddress = data["originIpAddress"] as? String {
                        result.updateValue(ipAddress, forKey: .ipAddress)
                        data.removeValue(forKey: "originIpAddress")
                    }

                    // Add the user-agent to the result, then remove from dictionary.
                    if let userAgent = data["originUserAgent"] as? String {
                        result.updateValue(userAgent, forKey: .userAgent)
                        data.removeValue(forKey: "originUserAgent")
                    }

                    // Add the location name to the result, then remove from dictionary.
                    if let location = data["originLocation"] as? String {
                        result.updateValue(location, forKey: .location)
                        data.removeValue(forKey: "originLocation")
                    }

                    // Add the image to the result, then remove from dictionary.
                    if let imageUrl = data["imageURL"] as? String {
                        result.updateValue(imageUrl, forKey: .image)
                        data.removeValue(forKey: "imageURL")
                    }

                    // Assign the remaining values to TransactionAttribute.custom
                    if !data.isEmpty {
                        // Normalize the array of value for consistency with Cloud (CIV).  i.e [{"name":"name1", "value": "value1"}, ...]
                        var additionalData = [[String: Any]]()

                        data.forEach {
                            item in
                            additionalData.append(["name": item.key, "value": item.value])
                        }

                        if let customData = try? JSONSerialization.data(withJSONObject: additionalData), let customJson = String(data: customData, encoding: .utf8) {
                            result.updateValue(customJson, forKey: .custom)
                        }
                    }
                }
            }
        }

        // If there is no type in the array, add the default "request"
        if result.index(forKey: .type) == nil {
            result.updateValue(NSLocalizedString("PendingRequestTypeDefault", bundle: Bundle.module, comment: ""), forKey: .type)
        }

        return result
    }
}


