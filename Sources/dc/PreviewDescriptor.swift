//
// Copyright contributors to the IBM Verify Digital Credentials SDK for iOS project
//

import Foundation
import Core

/// An interface that a credential or proof request preview must implement.
public protocol PreviewDescriptor: Identifiable {
    /// A unique identifier for the preview.
    var id: String { get }
    
    /// The originating invitation offer URL.
    var url: URL { get }
    
    /// A string to display to the user.
    var label: String? { get }
    
    /// A human readable information about this preview.
    var comment: String? { get }
        
    /// The JSON representation of the preview data based on a credentail defination or proof request.
    var jsonRepresentation: Data? { get }
    
    /// The document type that is used to support a custom visual representation of the  attributes.
    var documentTypes: [String] { get }
}

/// The preview of an invitation.
internal struct InvitationPreviewInfo: PreviewDescriptor {
    let id: String
    let url: URL
    let label: String?
    let comment: String?
    
    /// The type of invitation.
    let type: InvitationType
    
    /// An array of verifiable credential formats.
    let formats: [String]
    
    let jsonRepresentation: Data?
    
    internal let documentTypes: [String] = []
}

// MARK: Internal Structures

extension InvitationPreviewInfo {
    /// The type of invitation.
    enum InvitationType: String, Decodable {
        /// Offer a credential.
        case offerCredential = "https://didcomm.org/issue-credential/2.0/offer-credential"
        
        /// Request proof presentation.
        case requestPresentation = "https://didcomm.org/present-proof/2.0/request-presentation"
    }
    
    /// A requested credential that the holder can use to preview the credential.
    internal struct RequestAttach: Decodable {
        /// The credential identifier.
        let id: String
        
        /// Credential data offered by issuer.
        let data: Data
        
        private enum CodingKeys: String, CodingKey {
            case id = "@id"
            case data
        }
    }
}

extension InvitationPreviewInfo.RequestAttach {
    /// Credential data offered by issuer.
    internal struct Data: Decodable {
        /// JSON-LD object that represents the credential data.
        let json: JSON
    }
}

extension InvitationPreviewInfo.RequestAttach.Data {
    /// JSON object that represents the credential data.
    internal struct JSON: Decodable {
        /// The type of invitation.
        let type: InvitationPreviewInfo.InvitationType
        
        /// A human readable information about this credential offer.
        let comment: String?
        
        /// An array of verifiable credential formats.
        let formats: [[String: String]]
        
        /// The credential preview
        let credentialPreview: [String: AnyCodable]?
        
        /// An array of attachments that further define the credential being offered.
        let offersAttach: [AttachInfo]?
        
        /// An array of attachments that further define the credential being verified..
        let presentationAttach: [AttachInfo]?
        
        private enum CodingKeys: String, CodingKey {
            case type = "@type"
            case comment
            case formats
            case credentialPreview = "credential_preview"
            case offersAttach = "offers~attach"
            case presentationAttach = "request_presentations~attach"
        }
    }
}

extension InvitationPreviewInfo.RequestAttach.Data.JSON {
    /// An attachment that further defines the credential or verification request.
    internal struct AttachInfo: Decodable {
        /// Base64 encoded representation of the credential or verification data.
        let data: Data
        
        internal struct Data: Decodable {
            let base64: String
        }
    }
}

extension InvitationPreviewInfo: Decodable {
    // MARK: Enums

    /// The root level JSON structure for decoding.
    private enum CodingKeys: String, CodingKey {
        case invitation
    }
    
    private enum InvitationCodingKeys: String, CodingKey {
        case label
        case requestsAttach = "requests~attach"
        case url = "short_url"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // invitation
        let invitationContainer =  try container.nestedContainer(keyedBy: InvitationCodingKeys.self, forKey: .invitation)
        self.label = try invitationContainer.decodeIfPresent(String.self, forKey: .label)
        self.url = try invitationContainer.decode(URL.self, forKey: .url)
        
        // requests-attach, get the first item.
        guard let requestsAttach = try invitationContainer.decodeIfPresent([RequestAttach].self, forKey: .requestsAttach), let requestAttach = requestsAttach.first else {
            throw WalletError.failedToParse
        }
        
        self.id = requestAttach.id
        
        // json
        self.comment = requestAttach.data.json.comment
        self.type = requestAttach.data.json.type
        self.formats = requestAttach.data.json.formats.compactMap { $0["format"] }
        
        // offers-attach or request_presentations~attach.
        let attach = requestAttach.data.json.offersAttach ?? requestAttach.data.json.presentationAttach
        
        // Decode the Base64 string.
        guard let attach = attach, let attachItem = attach.first, let data = Data(base64Encoded: attachItem.data.base64) else {
            throw WalletError.failedToParse
        }
        
        // Check if "credentail_preview" is present, typically for Indy credential offers but not Indy credential verifications.
        if self.formats.allSatisfy(["hlindy-zkp-v1.0", ].contains), let credentialPreview = requestAttach.data.json.credentialPreview {
            // Map credential_preview to a regular dictionary.
            var dict = Dictionary.init(uniqueKeysWithValues: credentialPreview.map( {key, value in (key, value.value)} ))
        
            //  Create a dictionary from data and add "cred_def_id".
            if let base64 = try JSONSerialization.jsonObject(with: data) as? [String: Any], let schemaId = base64["cred_def_id"] as? String {
                dict.updateValue(schemaId, forKey: "cred_def_id")
            }

            // Serialize dictionary to JSON data and convert to String.
            let value = try JSONSerialization.data(withJSONObject: dict, options: [.fragmentsAllowed])
            self.jsonRepresentation = value
            
            return
        }
        
        // Serialize JSON to string.
        self.jsonRepresentation = data
    }
}
