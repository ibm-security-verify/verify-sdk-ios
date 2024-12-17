//
// Copyright contributors to the IBM Verify Digital Credentials SDK for iOS project
//

import Foundation
import UIKit
import Core

/// A Credential starts out as either an outbound request, if created by a holder, or an outbound offer, if created by an issuer. 
///
/// The state transitions for a credential as implemented by cloud agent are as follows:
///
/// - outbound_request (holder)
/// - inbound_request (issuer)
/// - outbound_offer (issuer)
/// - inbound_offer (holder)
/// - accepted OR rejected (holder)
/// - issued (issuer)
/// - stored (holder)
///
public struct IndyCredential: CredentialDescriptor {
    public let id: String
    public let role: CredentialRole
    public let state: CredentialState
    public let issuerDid: DID
    public let format: CredentialFormat = .indy
    public let jsonRepresentation: Data?
    public let documentTypes: [String]
    
    /// The definition identifier for the credential.
    public let credentialDefinitionId: String
    
    /// The schema that the credential is based on. For example "drivers_license".
    public let schemaName: String
    
    /// The version of the schema. For example "1.0".
    public let schemaVersion: String
    
    /// Extra metadata about the credential.
    public let properties: [String: AnyCodable]
    
    /// Connections represent a channel for communication between two agents.
    private let connection: ConnectionInfo
    
    /// The name of the agent of the holder.
    public var agentName: String {
        get {
            return connection.remote.name
        }
    }
    
    /// The URL of the holder.
    public var agentURL: URL {
        get {
            return connection.remote.agentURL
        }
    }
    
    /// An optional friendly name to display when someone looks at the credential offer.
    public var friendlyName: String?  {
        get {
            guard let name = self.properties["name"], let value = name.value as? String else {
                return nil
            }
            
            return value
        }
    }
    
    /// A  time to represent when the credential was offered.
    public var offerTime: Date  {
        get {
            let dateFormatter = DateFormatter.iso8061FormatterBehavior
            
            guard let time = self.properties["time"], let value = time.value as? String, let date = dateFormatter.date(from: value)  else {
                return Date.now
            }
            
            return date
        }
    }
    
    /// An icon to display when someone views the connection.
    public var icon: UIImage? {
        get {
            // Check if the icon value is present.
            if let icon = self.properties["icon"], let value = icon.value as? String, !value.isEmpty {
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
}

extension IndyCredential: Codable {
    // MARK: Enums

    /// The root level JSON structure for decoding.
    private enum CodingKeys: String, CodingKey {
        case id
        case role
        case state
        case issuerDid = "issuer_did"
        case connection
        case credentialDefinitionId = "cred_def_id"
        case schemaName = "schema_name"
        case schemaVersion = "schema_version"
        case format
        case properties
        case jsonRepresentation = "cred_json"
    }
    
    private enum RemoteCodingKeys: String, CodingKey {
        case agentName = "name"
        case agentUrl = "url"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.role = try container.decode(CredentialRole.self, forKey: .role)
        self.state = try container.decode(CredentialState.self, forKey: .state)
        self.issuerDid = try container.decode(DID.self, forKey: .issuerDid)
        self.connection = try container.decode(ConnectionInfo.self, forKey: .connection)
        self.credentialDefinitionId = try container.decode(String.self, forKey: .credentialDefinitionId)
        self.schemaName = try container.decode(String.self, forKey: .schemaName)
        self.schemaVersion = try container.decode(String.self, forKey: .schemaVersion)
        self.properties = try container.decodeIfPresent([String: AnyCodable].self, forKey: .properties) ?? [:]
        
        var jsonRepresentation: Data? = nil
        var documentTypes: [String] = []
        
        // Get the "cred_json" element data.
        if container.contains(.jsonRepresentation) {
            let data = try container.decode([String: AnyCodable].self, forKey: .jsonRepresentation)
            
            // For Indy get the cred_def_id.
            if let item = data["cred_def_id"], let type = item.value as? String {
                documentTypes = [type]
            }
            
            // Map to regular dictionary.
            let dict = Dictionary.init(uniqueKeysWithValues: data.map( {key, value in (key, value.value)} ))
            
            // Serialize dictionary to Data and convert to String.
            let value = try JSONSerialization.data(withJSONObject: dict, options: [.fragmentsAllowed])
            jsonRepresentation = value
        }
        
        self.jsonRepresentation = jsonRepresentation
        self.documentTypes = documentTypes
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(role, forKey: .role)
        try container.encode(state, forKey: .state)
        try container.encode(issuerDid, forKey: .issuerDid)
        try container.encode(connection, forKey: .connection)
        try container.encode(format, forKey: .format)
        try container.encode(credentialDefinitionId, forKey: .credentialDefinitionId)
        try container.encode(schemaName, forKey: .schemaName)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(properties, forKey: .properties)
        
        if let jsonRepresentation {
            // Convert the JSON String to a regular dictionary.
            let dict = try JSONSerialization.jsonObject(with: jsonRepresentation) as? [String: Any]
            
            // Map the dictionary to [String: AnyEncodable] for serialization.
            let value = AnyEncodable(dict)
            try container.encode(value, forKey: .jsonRepresentation)
        }
    }
}
