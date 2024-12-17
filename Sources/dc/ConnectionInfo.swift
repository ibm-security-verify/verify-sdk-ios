//
// Copyright contributors to the IBM Verify Digital Credentials SDK for iOS project
//

import Foundation
import UIKit
import Core

/// Represents the state of a connection.
public enum ConnectionState: String, Codable {
    /// The connection is an inbound offer to the holder.
    case inboundOffer = "inbound_offer"
    
    /// The connection is an outbound offer from the issuer.
    case outboundOffer = "outbound_offer"
    
    /// The connection has been establish.
    case connected
    
    /// The offer has been rejected.
    case rejected
}

/// A unique identifier use in communication on the Hyperledger Indy ledger.  They represent users, agents, issuers, verifiers, etc.
public typealias DID = String

/// A publicly shared key associated with a DID.  The DID owner proves ownership of the DID using the private/signing key associated with this verkey.
public typealias Verkey = String

/// Connections represent a channel for communication between two agents.
public struct ConnectionInfo: Identifiable {
    /// A unique identifier for this connection.
    public let id: String
    
    /// An icon to display when someone views the connection.
    public var icon: UIImage? {
        get {
            guard let invitation = invitation else {
                return nil
            }
            
            // Check if the icon value is present.
            if let icon = invitation.properties["icon"], let value = icon.value as? String {
                // Get the base64 value.
                if value.components(separatedBy: "base64,").count == 2 {
                    // Convert base64-encoded String to UIImage.
                    if let data = Data(base64Encoded: value.components(separatedBy: "base64,")[1]), let image = UIImage(data: data) {
                        return image
                    }
                }
                return nil
            }
            return nil
        }
    }
    
    /// A friendly name to display when someone views the connection.
    public var name: String {
        get {
            return remote.name
        }
    }
    
    /// This agent's role in the connection.  Can be 'offerer' or 'offeree'.
    public let role: String
   
    /// The state of the connection.
    public let state: ConnectionState
    
    /// Invitations represent a way for one agent to exchange its endpoint information with another agent.
    private let invitation: InvitationInfo?
    
    /// Information about this agent's role in the connection. Only present if this agent has accepted or initiated the connection.
    public let local: ConnectionAgentInfo
    
    /// Information about the other agent's role in this connection. Only present if that agent accepted or initiated the connection.
    public let remote: ConnectionAgentInfo
}

extension ConnectionInfo: Codable {
    // MARK: Enums

    /// The root level JSON structure for decoding.
    private enum CodingKeys: String, CodingKey {
        case id
        case role
        case state
        case invitation
        case local
        case remote
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.role = try container.decode(String.self, forKey: .role)
        self.state = try container.decode(ConnectionState.self, forKey: .state)
        self.invitation = try container.decodeIfPresent(InvitationInfo.self, forKey: .invitation)
        self.local = try container.decode(ConnectionAgentInfo.self, forKey: .local)
        self.remote = try container.decode(ConnectionAgentInfo.self, forKey: .remote)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(role, forKey: .role)
        try container.encode(state, forKey: .state)
        try container.encodeIfPresent(invitation, forKey: .invitation)
        try container.encode(local, forKey: .local)
        try container.encode(remote, forKey: .remote)
    }
}

/// Information about an agent involved in an ``ConnectionInfo``.
public struct ConnectionAgentInfo {
    /// The name of the agent
    public let name: String
    
    /// The URL needed to connect to the agent.
    public let agentURL: URL
    
    /// Identifying information dedicated to this specific connection.
    public let pairwise: (did: DID, verkey: Verkey)

    /// Identifying information that has been published to the ledger.
    public private(set) var `public`: (did: DID, verkey: Verkey)?
}

extension ConnectionAgentInfo: Codable {
    // MARK: Enums

    /// The root level JSON structure for decoding.
    private enum CodingKeys: String, CodingKey {
        case name
        case agentURL = "url"
        case pairwise
        case `public`
    }
    
    private enum DIDVerkeyCodingKeys: String, CodingKey {
        case did
        case verkey
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.agentURL = try container.decode(URL.self, forKey: .agentURL)
        
        // DID and Verkey variables
        var did: DID
        var verkey: Verkey
        
        // Pairwise structure
        let pairwiseContainer = try container.nestedContainer(keyedBy: DIDVerkeyCodingKeys.self, forKey: .pairwise)
        did = try pairwiseContainer.decode(DID.self, forKey: .did)
        verkey = try pairwiseContainer.decode(Verkey.self, forKey: .verkey)
        pairwise = (did, verkey)
        
        // Public structure
        if container.contains(.public) {
            let publicContainer = try container.nestedContainer(keyedBy: DIDVerkeyCodingKeys.self, forKey: .public)
            did = try publicContainer.decode(DID.self, forKey: .did)
            verkey = try publicContainer.decode(Verkey.self, forKey: .verkey)
            self.public = (did, verkey)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(agentURL, forKey: .agentURL)
        
        // Pairwise structure
        var pairwiseContainer = container.nestedContainer(keyedBy: DIDVerkeyCodingKeys.self, forKey: .pairwise)
        try pairwiseContainer.encode(pairwise.did, forKey: .did)
        try pairwiseContainer.encode(pairwise.verkey, forKey: .verkey)
        
        // Public structure
        if let `public` = self.public {
            var publicContainer = container.nestedContainer(keyedBy: DIDVerkeyCodingKeys.self, forKey: .public)
            try publicContainer.encode(`public`.did, forKey: .did)
            try publicContainer.encode(`public`.verkey, forKey: .verkey)
        }
    }
}
