//
// Copyright contributors to the IBM Verify Digital Credentials SDK for iOS project
//

import Foundation
import Core

/// Represents the state of a ``CredentialDescriptor`` on the agent.  The state of a credential changes depending on whether a holder or an issuer is viewing the credential.
///
/// For example, if a holder creates the credential request, they will see the state of the credential as `outbound_request`, whil the issuer will see `inbound_request`.
public enum CredentialState: String, Codable {
    /// An outbound request for a credential.
    case outboundRequest = "outbound_request"
    
    /// An inbound request for a credential.
    case inboundRequest = "inbound_request"
    
    /// An outbound offer of a credential.
    case outboundOffer = "outbound_offer"
    
    /// An inbound request of a credential.
    case inboundOffer = "inbound_offer"
    
    /// The credential has been accepted.
    case accepted
    
    /// The credential has been rejected.
    case rejected
    
    /// The credential has been issued.
    case issued
    
    /// The credential has been stored in the wallet.
    case stored
    
    /// The credential failed to issue or be stored.
    case failed
    
    /// The credential has been deleted.
    case deleted
}

/// The action to use when processing a credential offer.
public enum CredentialAction: String {
    /// The credential has been accepted.
    case accepted
    
    /// The credential has been rejected.
    case rejected
}

/// The agent's relationship to the credential.
public enum CredentialRole: String, Codable {
    /// The issuer of the credential.
    case issuer
    
    /// The holder of the credential.
    case holder
}

/// The type of format of the credential.
public enum CredentialFormat: String, Codable {
    /// An Indy format being traditionally based on a ledge.
    case indy
    
    /// JSON-LD credential format expanding schemas.
    case jsonld
    
    /// mDoc format using the ISO-18013 specification.
    case mdoc = "mso_mdoc"
    
    /// Returns the `CredentialDescriptor` for a given format.
    var type: any CredentialDescriptor.Type {
        switch self {
        case .indy:
            return IndyCredential.self
        case .jsonld:
            return JSONLDCredential.self
        case .mdoc:
            return MDocCredential.self
        }
    }
}

/// An interface that a credential must implement.
public protocol CredentialDescriptor: Identifiable, Codable {
    /// A unique identifier for this credential.
    var id: String { get }
    
    /// The format that describes the internal credential structure.
    var format: CredentialFormat { get }
    
    /// The agent's relationship to the credential.
    var role: CredentialRole { get }
    
    /// The current state of the credential.
    ///
    ///  This field when updated will turn credential offers into stored credentials.
    var state: CredentialState { get }
    
    /// The Issuer's public DID.
    var issuerDid: DID { get }
    
    /// The JSON representation of the credential.
    var jsonRepresentation: Data? { get }
    
    /// The document type that is used to support a custom visual representation of the credential.
    var documentTypes: [String] { get }
}

/// Invokes the decoder for a given `CredentialFormat`.
public struct Credential: Codable {
    /// The type of credential.
    public let type: any CredentialDescriptor
    
    /// A unique identifier for this credential.
    public var id: String {
        type.id
    }
    
    /// The document type that is used to support a custom visual representation of the credential.
    public var documentTypes: [String] {
        get {
            type.documentTypes
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case format
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let format = try container.decode(CredentialFormat.self, forKey: .format)
        
        self.type = try format.type.init(from: decoder)
    }
    
    public func encode(to encoder: any Encoder) throws {
        try type.encode(to: encoder)
    }
}
