//
// Copyright contributors to the IBM Verify Digital Credentials SDK for iOS project
//

import Foundation
import Core
import Authentication


// MARK: Wallet

public struct Wallet: WalletDescriptor {
    /// The location of the endpoint to refresh the OAuth token for the wallet.
    public let refreshUri: URL

    /// The location of the endpoint to perform digital credential operations.
    public let baseUri: URL
    
    /// The client identifier issued to the client during the registration process.
    public let clientId: String
    
    /// The client secret.
    public var clientSecret: String?
    
    /// The authorization server issues an access token and optional refresh token.  In addition the `TokenInfo` provides the token type and other properties supporting the access token.
    public var token: TokenInfo
    
    /// An `Agent` manages credentials and is used to connect to other agents on behalf of the user.
    public let agent: AgentInfo
    
    /// An array of  connections for communication between two agents.
    public var connections: [ConnectionInfo]
    
    /// An array of invitations for one agent to exchange its endpoint information with another agent.
    public var invitations: [InvitationInfo]
    
    /// An array of credentials.
    public var credentials: [Credential]
}

extension Wallet {
    // MARK: Enums

    /// The root level JSON structure for decoding.
    private enum CodingKeys: CodingKey {
        case refreshUri
        case baseUri
        case clientId
        case clientSecret
        case token
        case agent
        case connections
        case invitations
        case credentials
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.refreshUri = try container.decode(URL.self, forKey: .refreshUri)
        self.baseUri = try container.decode(URL.self, forKey: .baseUri)
        self.clientId = try container.decode(String.self, forKey: .clientId)
        self.clientSecret = try container.decodeIfPresent(String.self, forKey: .clientSecret)
        self.token = try container.decode(TokenInfo.self, forKey: .token)
        self.agent = try container.decode(AgentInfo.self, forKey: .agent)
        self.connections = try container.decode([ConnectionInfo].self, forKey: .connections)
        self.invitations = try container.decode([InvitationInfo].self, forKey: .invitations)
        self.credentials = try container.decode([Credential].self, forKey: .credentials)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(refreshUri, forKey: .refreshUri)
        try container.encode(baseUri, forKey: .baseUri)
        try container.encode(clientId, forKey: .clientId)
        try container.encodeIfPresent(clientSecret, forKey: .clientSecret)
        try container.encode(token, forKey: .token)
        try container.encode(agent, forKey: .agent)
        try container.encode(connections, forKey: .connections)
        try container.encode(invitations, forKey: .invitations)
        try container.encode(credentials, forKey: .credentials)
    }
}
