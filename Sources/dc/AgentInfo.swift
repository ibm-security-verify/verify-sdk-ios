//
// Copyright contributors to the IBM Verify Digital Credentials SDK for iOS project
//

import Foundation

/// An `Agent` manages credentials and is used to connect to other agents on behalf of the user.
public struct AgentInfo: Identifiable {
    /// The identifier of the agent.
    public let id: String
    
    /// The name of the agent
    public let name: String
    
    /// The URL needed to connect to the agent.
    public let agentURL: URL
    
    /// The URL that represents the agent in a connection object.
    public let connectionURL: URL
    
    /// The public key for the agent.
    public let verkey: Verkey
    
    /// The DID for the agent.
    public let did: DID
    
    /// The date and time when the agent was created.
    public let creationDate: Date
}

extension AgentInfo: Codable {
    // MARK: Enums

    /// The root level JSON structure for decoding.
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case agentURL = "url"
        case connectionURL = "connection_url"
        case verkey
        case did
        case creationDate = "creation_time"
    }
}
