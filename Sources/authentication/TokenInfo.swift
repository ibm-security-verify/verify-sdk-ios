//
// Copyright contributors to the IBM Security Verify Authentication SDK for iOS project
//


import Foundation
import Core

/// The authorization server issues an access token and optional refresh token.  In addition the ``TokenInfo`` provides the token type and other properties supporting the access token.
///
/// When retrieving the `TokenInfo` from a persisted state, ensure the [JSONDecoder.dateDecodingStrategy](https://developer.apple.com/documentation/foundation/jsondecoder/datedecodingstrategy) is assigned.
///
/// ```swift
/// let json = """
/// {
///   "tokenType": "Bearer",
///   "refreshToken": "h5j6i7k8",
///   "accessToken": "a1b2c3d4",
///   "expiresOn": "2022-12-30T11:30:31.340Z",
///   "expiresIn": 7200
/// }
///
/// let decoder = JSONDecoder()
/// decoder.dateDecodingStrategy = .formatted(.iso8061FormatterBehavior)
///
/// let token = try decoder.decode(TokenInfo.self, from: json.data(using: .utf8)!)
///
/// // Print token
/// print(token)
/// ```
public struct TokenInfo: Codable {
    /// The access token generated by the authorization server.
    public let accessToken: String
    
    /// The refresh token, which can be used to obtain new access tokens using the same authorization grant.
    /// - Remark: The `refresh_token` is optional.
    public let refreshToken: String?
    
    /// The lifetime in seconds of the access token.
    ///
    /// For example, the value "3600" denotes that the access token will expire in one hour from the time the response was generated.
    public let expiresIn: Int
    
    /// Typically "Bearer" when present. Otherwise, another `tokenType` value that the Client has negotiated with the Authorization Server.
    public let tokenType: String
    
    /// The scope of the access token.
    ///
    /// If the scope the user granted is identical to the scope the app requested, this parameter is optional. If the granted scope is different from the requested scope, such as if the user modified the scope, then this parameter is required.
    /// - Remark: The `scope` is optional.
    public let scope: String?
    
    /// Additional data parameters returned from the token server.
    public let additionalData: [String: Any]
    
    /// The type of token that the authorization server will return which encodes the user’s authentication information.
    /// - Remark: The `id_token` is optional.
    public let idToken: String?
    
    /// Creates authorization header from token type and access token.  The authorization header is used in subsequent HTTP requests.
    /// - Returns: An authorization header.  For example: `Bearer ABC123`.
    public var authorizationHeader: String {
        return "\(tokenType) \(accessToken)"
    }
    
    /// The date the access token expires.
    ///
    /// When the token is obtained from the authorization server, the `expiresOn` date is calculated from now plus the ```expiresIn``` value.
    ///
    /// The `expiresOn` is used for determining ```tokenExpired``` and ```shouldRefresh```.
    public let expiresOn: Date

    /// The flag to indicate if the access token has expired.
    public var tokenExpired: Bool {
        return Date().compare(expiresOn) == ComparisonResult.orderedDescending
    }

    /// The flag to indicate if the access token should be refreshed.
    /// - Remark: `true` when 90% of the token lifetime has elapsed since the token created date, otherwise `false`.
    public var shouldRefresh: Bool {
        return Double(expiresIn) * 0.1 > expiresOn.timeIntervalSinceNow
    }
    
    // MARK: Internal Enum

    /// The root level JSON structure for decoding.
    private enum CodingKeys: String, CodingKey {
        case accessToken, access_token
        case refreshToken, refresh_token
        case idToken, id_token
        case expiresIn, expires_in
        case expiresOn = "expires_on"
        case tokenType = "token_type"
        case scope
        case addtionalParameters
    }
 
    /// Creates a new instance by decoding from the given decoder
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        // OAuth keys
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)

        // Access token
        self.accessToken = try rootContainer.decode(String.self, forKeys: [.accessToken, .access_token])

        // Refresh token
        self.refreshToken = try rootContainer.decodeIfPresent(String.self, forKeys: [.refreshToken, .refresh_token])

        // Expires in
        self.expiresIn = try rootContainer.decode(Int.self, forKeys: [.expiresIn, .expires_in])

        // Expires On
        self.expiresOn = try rootContainer.decodeIfPresent(Date.self, forKey: .expiresOn) ?? Date(timeIntervalSinceNow: TimeInterval(expiresIn))

        // Token type
        self.tokenType = try rootContainer.decodeIfPresent(String.self, forKey: .tokenType) ?? "Bearer"

        // Scopes
        self.scope = try rootContainer.decodeIfPresent(String.self, forKey: .scope)
        
        // ID Token
        self.idToken = try rootContainer.decodeIfPresent(String.self, forKeys: [.idToken, .id_token])

        // Additional data key
        let unknownContainer = try decoder.container(keyedBy: UnknownCodingKeys.self)
        self.additionalData = unknownContainer.decode(exclude: CodingKeys.self)
    }

    /// Encodes this value into the given encoder.
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        // Additional parameters key
        var unknownContainer = encoder.container(keyedBy: UnknownCodingKeys.self)
        try unknownContainer.encode(withDictionary: additionalData)

        // OAuth keys
        var rootContainer = encoder.container(keyedBy: CodingKeys.self)
        try rootContainer.encode(accessToken, forKey: .accessToken)
        try rootContainer.encode(tokenType, forKey: .tokenType)
        try rootContainer.encodeIfPresent(refreshToken, forKey: .refreshToken)
        try rootContainer.encode(expiresIn, forKey: .expiresIn)
        try rootContainer.encode(expiresOn, forKey: .expiresOn)
        try rootContainer.encodeIfPresent(idToken, forKey: .idToken)
        try rootContainer.encodeIfPresent(scope, forKey: .scope)
    }
}

/// The authorization server issues an access token and optional refresh token.  In addition the `TokenInfo` provides the token type and other properties supporting the access token.
extension TokenInfo: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values a and b, `a == b` implies that `a != b` is `false`.
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    /// - Returns: Boolean result.
    public static func == (lhs: TokenInfo, rhs: TokenInfo) -> Bool {
        return lhs.refreshToken == rhs.refreshToken &&
        lhs.accessToken == rhs.accessToken &&
        lhs.expiresIn == rhs.expiresIn &&
        lhs.tokenType == rhs.tokenType
    }
}
