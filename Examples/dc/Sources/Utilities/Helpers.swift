//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import Foundation
import Core
import DC

/// Parse the attributes to format the credential presentation.
/// - Parameters:
///   - json: A binary representation of the JSON data.
/// - Returns: An instance of the typed object.
func formatCredential<T: Decodable>(using json: Data) -> T {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try! decoder.decode(T.self, from: json)
}


/// Parses ``VerificationInfo`` retrieving proof request name, purpose and date.
/// - Parameter info: An instance of ``VerificationInfo``.
/// - Returns: A tupple representing the `name`, `purpose` and `created date`.
func proofRequestMetadata(verification: VerificationInfo) -> (name: String, purpose: String, date: Date) {
    // For mdoc and jsonld based verifications.
    var request: ProofRequest.PresentationRequest?
    if verification.proofRequest.jsonId != nil {
        request = verification.proofRequest.jsonId
    }
    if verification.proofRequest.mdoc != nil {
        request = verification.proofRequest.mdoc
    }
    
    if let request = request, let inputDescriptors = request.presentationDefination.inputDescriptors, let inputDescriptor = inputDescriptors.first, let name = inputDescriptor.name, let purpose = inputDescriptor.purpose {
            return (name: name, purpose: purpose, date: verification.timestamps.created)
    }
    
    if let name = verification.proofRequest.name, let purpose = verification.proofDisplay {
        return (name: name, purpose: purpose, date: verification.timestamps.created)
    }
    
    return (name:"Unknown", purpose: "Unknown", date: Date())
}

/// Parses ``VerificationInfo`` retrieving proof request name, purpose and date.
/// - Parameter info: An instance of ``VerificationInfo``.
/// - Returns: An array of ``ProofItem`` representing the verification of each claim.
func proofCredentialMetadata(verification: VerificationInfo) -> [ProofItem]  {
    var result: [ProofItem] = []
    
    if let info = verification.info, let infoValue = info.value as? [String: Any] {
        // For mdoc and indy we grab the data from "info.attributes".
        if verification.proofRequest.jsonId == nil, let attributes = infoValue["attributes"] as? [[String: Any]] {
            attributes.forEach { attribute in
                result = attribute.compactMap { item -> ProofItem? in
                    guard let value = item.value as? String else {
                        return nil
                    }
                    
                    return ProofItem(id: item.key, value: value)
                }
            }
        }
        
        // For JSON-LD, the verification data is contained in the "verifiableCredential" array.
        if let verifiableCredentials = infoValue["verifiableCredential"] as? [[String: Any]] {
            verifiableCredentials.forEach { verifiableCredential in
                if let credentialSubject = verifiableCredential["credentialSubject"] as? [String: Any] {
                    result = credentialSubject.compactMap { item -> ProofItem? in
                        guard let value = item.value as? String else {
                            return nil
                        }
                        
                        return ProofItem(id: item.key, value: value)
                    }
                }
            }
        }
    }
    
    return result
}

/// A structure representing the proof claim.
internal struct ProofItem: Identifiable {
    /// The identifier of the claim.
    let id: String
    
    /// The value of the claim verified.
    let value: String
}
