//
// Copyright contributors to the IBM Security Verify Authentication SDK for iOS project
//

import Foundation
import Core
import OSLog
import AuthenticationServices
import CryptoKit

/// A type that indicates when OAuth operartion encounters an error.
public enum OAuthProviderError: Error, LocalizedError, Equatable {
    /// The authorization request received an invalid response.
    case invalidResponse
    
    /// The authorization attempt failed.
    case failed
    
    /// The authorization attempt failed for an unknown reason.
    case general(message: String)
    
    public var errorDescription: String? {
       switch self {
       case .invalidResponse:
            return NSLocalizedString("The authorization request received an invalid response.", comment: "Invalid response")
       case .failed:
            return NSLocalizedString("The authorization attempt failed.", comment: "Failed")
       case .general(message: let message):
           return NSLocalizedString(message, comment: "General error")
       }
   }
}

/// A method used to derive code challenge.
public enum CodeChallengeMethod: String {
    /// The plain transformation is for compatibility with existing deployments and for constrained environments that can't use the S256 transformation.
    case plain
    
    /// The client uses output of a suitable random number generator to create a 32-octet sequence.
    ///
    /// The S256 method protects against eavesdroppers observing or intercepting the `code_challenge`, because the challenge cannot be used without the verifier.
    case S256
}

/// The OAuthProvider enables third-party applications to obtain limited access to an HTTP service, either on behalf of a resource owner by orchestrating an approval interaction between the resource owner and the HTTP service, or by allowing the third-party application to obtain access on its own behalf.
public class OAuthProvider {
    // MARK: Variables
    private let logger: Logger
    private let serviceName = Bundle.main.bundleIdentifier!
    
    /// The client identifier issued to the client during the registration process.
    let clientId: String
    
    /// The client secret.
    let clientSecret: String?
    
    /// The request’s timeout interval, in seconds.  Default is 30 seconds.
    ///
    /// If during a connection attempt the request remains idle for longer than the timeout interval, the request is considered to have timed out.
    var timeoutInterval: TimeInterval

    /// Additional HTTP headers of the request.
    var additionalHeaders: [String: String] = [:]
    
    /// The client's additional authorization parameters.
    var additionalParameters: [String: String]
    
    /// A delegate that the OAuth provider informs about the success or failure of  an authorization request via the browser.
    public weak var delegate: OAuthProviderDelegate?
    
    
    /// Initializes the `OAuthProvider`.
    /// - parameter clientId: The client identifier issued to the client during the registration process.
    /// - parameter clientSecret: The client secret.
    /// - parameter timeoutInterval: The request’s timeout interval, in seconds.  Default is 30 seconds.
    /// - parameter additonalParameters: The client's additional authorization parameters.
    public init(clientId: String, clientSecret: String? = nil, timeoutInterval: TimeInterval = 30, additionalParameters: [String: String] = [:]) {
        logger = Logger(subsystem: serviceName, category: "oauth")
        
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.timeoutInterval = timeoutInterval
        self.additionalParameters = additionalParameters
    }
    
    // MARK: - OIDC Discovery
    
    /// Discover the authorization service configuration from a compliant OpenID Connect endpoint.
    /// - parameter url: The `URL` for the OpenID Connect service provider issuer.
    /// - parameter completion: The closure to invoke when the discovery completes.
    static func discover(issuer url: URL, completion: @escaping (Result<OIDCMetadataInfo, Error>) -> Void) {
        // Check for the .well-known/openid-configuration
        if !url.path.hasSuffix(".well-known/openid-configuration") {
            completion(.failure(URLError(.badURL, userInfo: ["reason": "The URL does not end with the .well-known/openid-configuration path component."])))
        }
        
        let resource = HTTPResource<OIDCMetadataInfo>(json: .get, url: url)
        
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Pre-authorization
    
    /// Launches the browser to initiate the authorization code (AZN) flow using optional Proof Key for Code Exchange (PKCE).
    /// - parameter url: The `URL` to the authorize endpoint for the OpenID Connect service provider issuer.
    /// - parameter redirectUrl: The redirect `URL` that is registered with the OpenID Connect service provider.
    /// - parameter presentingViewController: Provides a display context in which the system can present an authentication session to the user.
    /// - parameter codeChallenge: The scope of the access request.
    /// - parameter method: The hash method used to derive code challenge.
    /// - parameter scope: The scope of the access request. Default is **openid**.
    /// - parameter state: An opaque value used by the client to maintain state between the request and callback.  The authorization server includes this value when redirecting back to the client.
    /// - parameter shareSession: A Boolean value that indicates whether the session should ask the browser for a private authentication session.
    public func authorizeWithBrowser(issuer url: URL, redirectUrl: URL, presentingViewController: ASWebAuthenticationPresentationContextProviding, codeChallenge: String? = nil, method: CodeChallengeMethod? = .plain, scope: [String]? = ["openid"], state: String? = nil, shareSession: Bool = false) {
        // Create the parameters to encode into the body.
        var parameters = ["response_type": "code",
                          "client_id": self.clientId,
                          "redirect_uri": redirectUrl.absoluteString]
        
        if let clientSecret = self.clientSecret {
            parameters.updateValue(clientSecret, forKey: "client_secret")
        }
        
        if let codeChallenge = codeChallenge, let method = method {
            parameters.updateValue(codeChallenge, forKey: "code_challenge")
            parameters.updateValue(method.rawValue, forKey: "code_challenge_method")
        }
        
        if var scope = scope {
            scope.append("oidc")    // Add oidc if custom scopes are passed.
            parameters.updateValue(scope.joined(separator: " "), forKey: "scope")
        }
        
        if let state = state {
            parameters.updateValue(state, forKey: "state")
        }
        
        self.additionalParameters.forEach { param in
            parameters.updateValue(param.value, forKey: param.key)
        }
        
        // Construct the URL.
        var component = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        component.queryItems = component.queryItems ?? []
        component.queryItems!.append(contentsOf: parameters.map { URLQueryItem(name: $0.key, value: $0.value) })

        // Launch browser
        if let url = component.url {
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: redirectUrl.scheme, completionHandler: webAuthenticationSessionCallback)
            session.prefersEphemeralWebBrowserSession = !shareSession
            session.presentationContextProvider = presentingViewController
            session.start()
        }
        
        os_log("Failed to initiate browser.", log: .default, type: .info)
    }

    /// A completion handler the `ASWebAuthenticationSession` calls when it completes successfully, or when the user cancels the session.
    /// - parameter redirect: The value that identifies the location of a resource from the OpenID Connect service provider
    /// - parameter error: A type representing an error value that was thrown.
    private func webAuthenticationSessionCallback(redirect url: URL?, error: Error?) {
        // Handle the redirect response.
        guard error == nil, let url = url else {
            delegate?.oauthProvider(provider: self, didCompleteWithError: error!)
            return
        }

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        // Decode URL query parameters as a dictionary and check for code and state or error.
        var parameters: [String: String?] = [:]
        components.queryItems?.forEach { parameters[$0.name] = $0.value }
        
        guard let code = parameters["code"] as? String else {
            delegate?.oauthProvider(provider: self, didCompleteWithError: OAuthProviderError.invalidResponse)
            return
        }
        
        delegate?.oauthProvider(provider: self, didCompleteWithCode: (code, parameters["state"] ?? nil))
    }
    
    
    // MARK: - Authorization
    
    /// The authorization code is obtained by using an authorization server as an intermediary between the client and resource owner.
    /// - parameter url: The `URL` for the OpenID Connect service provider issuer.
    /// - parameter redirectUrl: The redirect `URL` that is registered with the OpenID Connect service provider. This parameter is requirred when the code was obtained through `authorizeWithBrowser`.
    /// - parameter authorizationCode: The authorization code received from the authorization server.
    /// - parameter codeVerifier: The PKCE code verifier used to redeem the authorization code.
    /// - parameter scope: The scope of the access request.
    /// - parameter completion: The closure to invoke when the code authorize completes.
    public func authorize(issuer url: URL, redirectUrl: URL?, authorizationCode: String, codeVerifier: String?, scope: [String]? = nil, completion: @escaping (Result<TokenInfo, Error>) -> Void) {
        // Create the parameters to encode into the body.
        var parameters = ["grant_type": "authorization_code",
                          "client_id": self.clientId,
                          "code": authorizationCode]
        
        if let redirectUrl = redirectUrl {
            parameters.updateValue(redirectUrl.absoluteString, forKey: "redirect_uri")
        }
        
        if let clientSecret = self.clientSecret {
            parameters.updateValue(clientSecret, forKey: "client_secret")
        }
        
        if let scope = scope {
            parameters.updateValue(scope.joined(separator: " "), forKey: "scope")
        }
        
        if let codeVerifier = codeVerifier {
            parameters.updateValue(codeVerifier, forKey: "code_verifier")
        }
        
        self.additionalParameters.forEach { param in
            parameters.updateValue(param.value, forKey: param.key)
        }
        
        // Generate the URL encoded body.
        let body = urlEncode(from: parameters).data(using: .utf8)!
        
        // Create the Http resource
        let resource = HTTPResource<TokenInfo>(.post,
                                               url: url,
                                               accept: .json,
                                               contentType: .urlEncoded,
                                               body: body,
                                               headers: self.additionalHeaders,
                                               timeOutInterval: self.timeoutInterval) { data, response in
            
            guard let data = data else {
                return Result.failure(URLSessionError.noData)
            }
            
            do {
                let value = try JSONDecoder().decode(TokenInfo.self, from: data)
                return Result.success(value)
            }
            catch let error {
                return Result.failure(error)
            }
        }
        
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// The resource owner password credentials (i.e., username and password) can be used directly as an authorization grant to obtain an access token.
    /// - parameter url: The `URL` for the OpenID Connect service provider issuer.
    /// - parameter userName: The resource owner username.
    /// - parameter password: The resource owner password.
    /// - parameter scope: The scope of the access request.
    /// - parameter completion: The closure to invoke when the username password authorization completes.
    public func authorize(issuer url: URL, username: String, password: String, scope: [String]? = nil, completion: @escaping (Result<TokenInfo, Error>) -> Void) {
        // Create the parameters to encode into the body.
        var parameters = ["grant_type":"password",
                          "client_id": self.clientId,
                          "username": username,
                          "password": password]
        
        if let clientSecret = self.clientSecret {
            parameters.updateValue(clientSecret, forKey: "client_secret")
        }
        
        if let scope = scope {
            parameters.updateValue(scope.joined(separator: " "), forKey: "scope")
        }
        
        self.additionalParameters.forEach { param in
            parameters.updateValue(param.value, forKey: param.key)
        }
        
        // Generate the URL encoded body.
        let body = urlEncode(from: parameters).data(using: .utf8)!
        
        // Create the Http resource
        let resource = HTTPResource<TokenInfo>(.post,
                                               url: url,
                                               accept: .json,
                                               contentType: .urlEncoded,
                                               body: body,
                                               headers: self.additionalHeaders,
                                               timeOutInterval: self.timeoutInterval) { data, response in
            
            guard let data = data else {
                return Result.failure(URLSessionError.noData)
            }
            
            do {
                let value = try JSONDecoder().decode(TokenInfo.self, from: data)
                return Result.success(value)
            }
            catch let error {
                return Result.failure(error)
            }
        }
        
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Refresh tokens are issued to the client by the authorization server and are used to obtain a new access token when the current access token becomes invalid or expires, or to obtain additional access tokens with identical or narrower scope.
    ///
    /// Because refresh tokens are typically long-lasting credentials used to request additional access tokens, the refresh token is bound to the client to which it was issued.
    ///
    /// - parameter url: The `URL` for the OpenID Connect service provider issuer.
    /// - parameter clientId: The client identifier issued to the client during the registration process.
    /// - parameter clientSecret: The client secret.
    /// - parameter scope: The scope of the access request.  The requested scope must not include any scope not originally granted by the resource owner, and if omitted is treated as equal to the scope originally granted by the resource owner.
    /// - parameter completion: The closure to invoke when the discovery completes.
    public func refresh(issuer url: URL, refreshToken: String, scope: [String]? = nil, completion: @escaping (Result<TokenInfo, Error>) -> Void) {
        // Create the parameters to encode into the body.
        var parameters = ["grant_type": "refresh_token",
                          "client_id": self.clientId,
                          "refresh_token": refreshToken]
        
        if let clientSecret = self.clientSecret {
            parameters.updateValue(clientSecret, forKey: "client_secret")
        }
        
        if let scope = scope {
            parameters.updateValue(scope.joined(separator: " "), forKey: "scope")
        }
        
        self.additionalParameters.forEach { param in
            parameters.updateValue(param.value, forKey: param.key)
        }
        
        // Generate the URL encoded body.
        let body = urlEncode(from: parameters).data(using: .utf8)!
        
        // Create the Http resource
        let resource = HTTPResource<TokenInfo>(.post,
                                               url: url,
                                               accept: .json,
                                               contentType: .urlEncoded,
                                               body: body,
                                               headers: self.additionalHeaders,
                                               timeOutInterval: self.timeoutInterval) { data, response in
            
            guard let data = data else {
                return Result.failure(URLSessionError.noData)
            }
            
            do {
                let value = try JSONDecoder().decode(TokenInfo.self, from: data)
                return Result.success(value)
            }
            catch let error {
                return Result.failure(error)
            }
        }
        
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: Protocols

/// An interface for providing information about the outcome of an authorization code flow request initiated via the browser.
public protocol OAuthProviderDelegate: AnyObject {
    /// Tells the delegate when the initial authorization flow fails, and provides an error explaining why.
    /// - parameter provider: The provider that performs the authorization attempt.
    /// - parameter error: An error that explains the failure.
    func oauthProvider(provider: OAuthProvider, didCompleteWithError error: Error)
    
    /// Tells the delegate when the initial authorization flow completes successfully.
    /// - parameter provider: The provider that performs the authorization attempt.
    /// - parameter result: The response containing the a authorization code and the state if provided in the initiating request.
    func oauthProvider(provider: OAuthProvider, didCompleteWithCode result: (code: String, state: String?))
}
