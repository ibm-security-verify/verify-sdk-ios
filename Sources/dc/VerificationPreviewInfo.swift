//
// Copyright contributors to the IBM Verify Digital Credentials SDK for iOS project
//

import Foundation
import Core

/// The preview of a credential verification.
public struct VerificationPreviewInfo: PreviewDescriptor {
    public let id: String
    public let url: URL
    public let label: String?
    public let comment: String?
    public let jsonRepresentation: Data?
    
    /// The document type that is used to support a custom visual representation of the `attributes`.
    public let documentTypes: [String]
    
    /// The title of name of the verification.
    public let name: String
    
    /// The purpose of the verification request
    public let purpose: String
}

extension VerificationPreviewInfo {
    internal init(using info: InvitationPreviewInfo) {
        self.id = info.id
        self.url = info.url
        self.label = info.label
        self.comment = info.comment
        
        var documentTypes: [String] = []
        var name = ""
        var purpose = ""
        
        // Create a dictionary from the JSON to check for document types.
        if let jsonRepresentation = info.jsonRepresentation, let data = try? JSONDecoder().decode([String: AnyCodable].self, from: jsonRepresentation) {
            // Use the formats to determine how to generate the documentTypes.
            if info.formats.allSatisfy(["dif/presentation-exchange/definition@v1.0"].contains) {
                // For mdoc, get the id in the "input_descriptors" level as the documentType.
                if let item = data["presentation_definition"], let presentationDefinition = item.value as? [String: Any], let inputDescriptors = presentationDefinition["input_descriptors"] as? [[String: Any]], let inputDescriptor = inputDescriptors.first, let id = inputDescriptor["id"] as? String, let nameValue = inputDescriptor["name"] as? String, let purposeValue = inputDescriptor["purpose"] as? String {
                    documentTypes = [id]
                    name = nameValue
                    purpose = purposeValue
                }
            }
            else if info.formats.allSatisfy(["hlindy/proof-req@v2.0"].contains) {
               // Obtain the name from the root structure.
                if let item = data["name"], let nameValue = item.value as? String {
                    name = nameValue
                }
                
                // Check if the "cred_def_id" is in the root structure, occurs when credential defination doens't apply a restriction on proof requests.
                if let item = data["cred_def_id"], let credDefinationId = item.value as? String {
                    documentTypes = [credDefinationId]
                }
                else if let requestedAttributes = data["requested_attributes"], let referents = requestedAttributes.value as? [String: Any] {
                    
                    var purposes: [String] = []
                    
                    // Search over the "requested_attributes" structure for the proof fields (referent) and the restrictions containing the "cred_def_id".
                    referents.forEach { (key: String, value) in
                        if let referent = value as? [String: Any], let restrictions = referent["restrictions"] as? [[String: Any]] {
                            
                            // Get the purpose represented by the "name" in the restrictions.
                            if let nameValue = referent["name"] as? String {
                                purposes.append(nameValue)
                            }
                            
                            restrictions.forEach { restriction in
                                restriction.forEach { item in
                                    if let value = item.value as? String {
                                        documentTypes.append(value)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Turn the purposes into a string.
                    purpose = purposes.joined(separator: " ")
                }
            }
            else {
                documentTypes = []
            }
        }
        
        self.documentTypes = documentTypes
        self.name = name
        self.purpose = purpose
        self.jsonRepresentation = info.jsonRepresentation
    }
}
