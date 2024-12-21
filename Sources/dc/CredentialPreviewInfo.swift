//
// Copyright contributors to the IBM Verify Digital Credentials SDK for iOS project
//

import Foundation
import Core

/// The preview of a credential on offer.
public struct CredentialPreviewInfo: PreviewDescriptor {
    public let id: String
    public let url: URL
    public let label: String?
    public let comment: String?
    public let jsonRepresentation: Data?
    public let documentTypes: [String]
}

extension CredentialPreviewInfo {
    internal init(using info: InvitationPreviewInfo) {
        self.id = info.id
        self.url = info.url
        self.label = info.label
        self.comment = info.comment
        
        var documentTypes: [String] = []
        
        // Create a dictionary from the JSON to check for document types.
        if let jsonRepresentation = info.jsonRepresentation, let data = try? JSONDecoder().decode([String: AnyCodable].self, from: jsonRepresentation) {
            // Use the formats to determine how to generate the documentTypes.
            if info.formats.allSatisfy(["mso_mdoc", "mso_mdoc_detail", "mso_mdoc_preview"].contains) {
                // For mdoc, get the root level element from the attribute as the documentType.
                // For Indy get the schema_id.
                if let item = data["docType"], let type = item.value as? String {
                    documentTypes = [type]
                }
            }
            else if info.formats.allSatisfy(["aries/ld-proof-vc-detail@v1.0"].contains) {
                // For JSON-LD, get the array of credential types
                if let item = data["credential"], let credential = item.value as? [String: Any], let type = credential["type"] as? [String] {
                    documentTypes = type
                }
            }
            else if info.formats.allSatisfy(["hlindy-zkp-v1.0"].contains) {
                // For Indy, get the "cred_def_id" from the base64 and the "credential_preview"
                if let item = data["cred_def_id"], let type = item.value as? String {
                    documentTypes = [type]
                }
            }
            else {
                documentTypes = []
            }
        }
        
        self.documentTypes = documentTypes
        self.jsonRepresentation = info.jsonRepresentation
    }
}
