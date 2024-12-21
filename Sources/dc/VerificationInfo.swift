//
// Copyright contributors to the IBM Verify Digital Credentials SDK for iOS project
//

import Foundation
import Core

/// The role being performed representing the state of the verification.
public enum VerificationRole: String, Codable {
    /// The verifier generates requests to the provider.
    case verifier = "verifier"
    
    /// The prover responds to requests initiated by the verifier.
    case prover = "prover"
}

/// State of the verification or proof request.
public enum VerificationState: String, Codable {
    /// Outbound verification request from the prover.
    case outboundVerificationRequest = "outbound_verification_request"
    
    /// Inbound verification request to the verifier.
    case inboundVerificationRequest = "inbound_verification_request"
    
    /// The proof has been provided by the prover to the verifier.
    case outboundProofRequest = "outbound_proof_request"
    
    /// The proof has been requested by the verifier to the prover.
    case inboundProofRequest = "inbound_proof_request"
    
    /// The proof has been generated by the prover.
    case proofGenerated = "proof_generated"
    
    /// The proof has been shared.
    case proofShared = "proof_shared"
    
    /// The request passed verification.
    case passed = "passed"
    
    /// The verification failed.
    case failed = "failed"
    
    /// The verification has been deleted.
    case deleted = "deleted"
}

/// The action to use when processing a verification request.
public enum VerificationAction: String {
    /// Generate the credential proof for verification
    case generate
    
    /// Share the credential proof for verification
    case share
    
    /// The request to prove a credential has been rejected.
    case reject
}

/// Represents all verification and proof requests between a prover and a verifier.  If created by the prover, the verifications initial state should be `outbound_verification_request`.  If created by a verifier, the initial state should be `outbound_proof_request` by the verifier.
public struct VerificationInfo: Identifiable {
    /// The ID of the verification.
    public let id: String
    
    /// The role being performed representing the state of the verification.
    public let role: VerificationRole
    
    /// State of the verification or proof request.
    ///
    /// Set by the verifier in the outbound proof request.
    public let state: VerificationState
    
    /// Verifer DID.
    public let verifierDID: DID
    
    /// Unique proof schema identifier
    public let proofSchemaId: String?
    
    /// Describes data that could be used to fill out a requested attribute in a proof request.  It's data describes information from a single credential in the agent's wallet.
    public let proofRequest: ProofRequest
    
    /// Display of the generated proof in JSON format.
    public let info: AnyCodable?
    
    /// Display of the generated proof.
    public let proofDisplay: String?
    
    /// Connections represent a channel for communication between two agents.
    public let connection: ConnectionInfo
    
    /// Additional properties associated with the verification..
    public let properties: [String: AnyCodable]?
    
    ///Timestamps associated with states of the credential.
    public let timestamps: (created: Date, states: [String: Date])
}

extension VerificationInfo: Decodable {
    // MARK: Enums

    /// The root level JSON structure for decoding.
    private enum CodingKeys: String, CodingKey {
        case id
        case role
        case state
        case verifierDID = "verifier_did"
        case proofSchemaId = "proof_schema_id"
        case proofRequest = "proof_request"
        case info
        case proofDisplay = "proof_display"
        case connection
        case properties
        case timestamps
    }
    
    private enum TimestampCodingKeys: Int, CodingKey {
        case created
        case states
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.role = try container.decode(VerificationRole.self, forKey: .role)
        self.state = try container.decode(VerificationState.self, forKey: .state)
        self.verifierDID = try container.decode(String.self, forKey: .verifierDID)
        self.proofSchemaId = try container.decodeIfPresent(String.self, forKey: .proofSchemaId)
        self.proofRequest =  try container.decode(ProofRequest.self, forKey: .proofRequest)
        self.info =  try container.decodeIfPresent(AnyCodable.self, forKey: .info)
        self.proofDisplay = try? container.decodeIfPresent(String.self, forKey: .proofDisplay)
        self.connection = try container.decode(ConnectionInfo.self, forKey: .connection)
        self.properties = try container.decodeIfPresent([String: AnyCodable].self, forKey: .properties)
        
        // Timestamp variables
        var created: Int
        var states: [String: Int]
        
        // Timestamp structure
        let timestampContainer = try container.nestedContainer(keyedBy: TimestampCodingKeys.self, forKey: .timestamps)
        created = try timestampContainer.decode(Int.self, forKey: .created)
        states = try timestampContainer.decode([String: Int].self, forKey: .states)
        
        // Convert the value from milliseconds to a Date.
        self.timestamps = (
            created: Date(timeIntervalSince1970: TimeInterval(created)),
            states: states.mapValues { value in
                Date(timeIntervalSince1970: TimeInterval(value))
            }
        )
    }
}
