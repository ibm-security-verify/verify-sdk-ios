//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI
import Core

// MARK: Views

/// Presentation of an Resident Citizen proof.
struct ResidentProofRequestView: View {
    @Environment(Model.self) private var model
    
    var jsonRepresentation: Data = Data()
    
    var body: some View {
        let items = displayRequestedClaims()
        List {
            Section(header: Text("Permanent Resident Check")) {
                ForEach(items) { item in
                    LabeledContent(item.id, value: item.value)
                }
            }
        }
    }
}

extension ResidentProofRequestView: ViewDescriptor {
    func displayRequestedClaims() -> [ProofItem] {
        var result: [ProofItem] = []
        
        if let verification = model.verificationGenerated, let info = verification.info, let infoValue = info.value as? [String: Any] {
            if let verifiableCredentials = infoValue["verifiableCredential"] as? [[String: Any]] {
                verifiableCredentials.forEach { verifiableCredential in
                    if let credentialSubject = verifiableCredential["credentialSubject"] as? [String: Any] {
                        if let value = credentialSubject["birthCountry"] as? String {
                            result.append(ProofItem(id: "Birth country", value: value))
                        }
                        
                        if let value = credentialSubject["familyName"] as? String {
                            result.append(ProofItem(id: "Family name", value: value))
                        }
                        
                        if let value = credentialSubject["givenName"] as? String {
                            result.append(ProofItem(id: "Given name", value: value))
                        }
                    }
                }
            }
        }
        return result
    }
}

/// Presentation of a resident offer.
struct ResidentCredentialOfferView: View {
    var jsonRepresentation: Data = Data()
    
    /// The credential associated with a university.
    private var credential: ResidentCredentialOffer {
        let value: ResidentCredentialOffer = formatCredential(using: jsonRepresentation)
        return value
    }
    
    var body: some View {
        List {
            LabeledContent("First name", value: credential.givenName)
                .multilineTextAlignment(.trailing)
            LabeledContent("Last name", value: credential.familyName)
                .multilineTextAlignment(.trailing)
            LabeledContent("Birth country", value: credential.birthCountry)
                .multilineTextAlignment(.trailing)
        }
    }
}
extension ResidentCredentialOfferView: ViewDescriptor { }

/// Presentation of a resident card.
struct ResidentCredentialCardView: View {
    var jsonRepresentation: Data = Data()
    
    /// The credential associated with a university.
    private var credential: ResidentCredentialCard {
        let value: ResidentCredentialCard = formatCredential(using: jsonRepresentation)
        return value
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(credential.fullName)
                .font(.title)
            Spacer()
            HStack {
                Text(Image(systemName: "globe.americas.fill"))
                Text("Birth country: \(credential.birthCountry)")
            }
            .padding(.bottom)
            Text("Issued: \(credential.issueDate)")
        }
        .foregroundStyle(.white)
        .padding()
        .background(Color(UIColor.systemBlue))
        .padding(8)
        .border(Color(UIColor.systemBlue), width: 4)
        .cornerRadius(8)
    }
}

extension ResidentCredentialCardView: ViewDescriptor { }

// MARK: Structures

/// Represents a verifable resident offer.
struct ResidentCredentialOffer: Decodable {
    /// Given name of the holder.
    let givenName: String
    
    /// Last name of the holder.
    let familyName: String
    
    /// The country of birth.
    let birthCountry: String
    
    /// Full name of holder.
    var fullName: String {
        get {
            return "\(givenName) \(familyName)"
        }
    }
    
    /// The root level JSON structure for decoding.
    private enum CodingKeys: String, CodingKey {
        case credential
    }
    
    private enum CredentialCodingKeys: String, CodingKey {
        case credentialSubject
    }
    
    private enum CredentialSubjectCodingKeys: String, CodingKey {
        case id
        case birthCountry
        case givenName
        case familyName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let credentialContainer = try container.nestedContainer(keyedBy: CredentialCodingKeys.self, forKey: .credential)
        let credentialSubjectContainer = try credentialContainer.nestedContainer(keyedBy: CredentialSubjectCodingKeys.self, forKey: .credentialSubject)
        
        self.givenName = try credentialSubjectContainer.decode(String.self, forKey: .givenName)
        self.familyName = try credentialSubjectContainer.decode(String.self, forKey: .familyName)
        self.birthCountry = try credentialSubjectContainer.decode(String.self, forKey: .birthCountry)
    }
}

/// Represents a verifable resident.
struct ResidentCredentialCard: Decodable {
    /// The identifier of the credential.
    let id: String
    
    /// Given name of the holder.
    let givenName: String
    
    /// Last name of the holder.
    let familyName: String
    
    /// The country of birth.
    let birthCountry: String
    
    /// Full name of holder.
    var fullName: String {
        get {
            return "\(givenName) \(familyName)"
        }
    }
    
    /// The issue date of the degree.
    let issueDate: Date
    
    /// The root level JSON structure for decoding.
    private enum CodingKeys: String, CodingKey {
        case credentialSubject
        case issuanceDate
    }
    
    private enum CredentialSubjectCodingKeys: String, CodingKey {
        case id
        case birthCountry
        case givenName
        case familyName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.issueDate = try container.decode(Date.self, forKey: .issuanceDate)
        
        // credentialSubject
        let credentialSubjectContainer = try container.nestedContainer(keyedBy: CredentialSubjectCodingKeys.self, forKey: .credentialSubject)
        self.id = try credentialSubjectContainer.decode(String.self, forKey: .id)
        self.givenName = try credentialSubjectContainer.decode(String.self, forKey: .givenName)
        self.familyName = try credentialSubjectContainer.decode(String.self, forKey: .familyName)
        self.birthCountry = try credentialSubjectContainer.decode(String.self, forKey: .birthCountry)
    }
}

// MARK: Previews

#Preview {
    let data = """
{
    "credential": {
        "id": "https://issuer.verify.ibm.com/credentials/1732680480100",
        "type": [
            "VerifiableCredential",
            "PermanentResidentCard"
        ],
        "credentialSubject": {
            "type": [
                "Person",
                "PermanentResident"
            ],
            "id": "did:example:b34ca6cd37bbf23",
            "birthCountry": "Australia",
            "familyName": "Breton",
            "givenName": "Jessica"
        },
        "@context": [
            "https://www.w3.org/2018/credentials/v1",
            "https://w3id.org/citizenship/v1",
            "https://w3id.org/security/suites/ed25519-2020/v1"
        ]
    },
    "options": {
      "proofPurpose": "assertionMethod",
      "proofType": "Ed25519VerificationKey2020"
    }
}

""".data(using: .utf8)!
    
    ResidentCredentialOfferView(jsonRepresentation: data)
}

#Preview {
    let data = """
{
    "id": "https://issuer.verify.ibm.com/credentials/1732680480100",
    "type": [
        "VerifiableCredential",
        "PermanentResidentCard"
    ],
    "credentialSubject": {
        "type": [
            "Person",
            "PermanentResident"
        ],
        "id": "did:example:b34ca6cd37bbf23",
        "birthCountry": "Australia",
        "familyName": "Breton",
        "givenName": "Jessica"
    },
    "@context": [
        "https://www.w3.org/2018/credentials/v1",
        "https://w3id.org/citizenship/v1",
        "https://w3id.org/security/suites/ed25519-2020/v1"
    ],
    "issuer": "did:web:diagency%3A9720:diagency:dids:v1.0:eec19c85-d8e7-4694-8520-19762b0e76f7",
    "issuanceDate": "2024-12-03T01:07:55Z",
    "proof": {
        "type": "Ed25519Signature2020",
        "created": "2024-12-03T01:07:55Z",
        "verificationMethod": "did:web:diagency%3A9720:diagency:dids:v1.0:eec19c85-d8e7-4694-8520-19762b0e76f7#z6MkvMzMN4mnVjGotaUSVHwLSgHEHRYUD75xJzvP5QYH9Gjn",
        "proofPurpose": "assertionMethod",
        "proofValue": "z34tWrAG1TVbQVHiVxAkbcAyBhHJrszkc9Z5831NBMrjHUSRTTyhMpWN2nkEhScCwydB6FEPqybf77qZ4BkraJ6rY"
    }
}
""".data(using: .utf8)!
    ResidentCredentialCardView(jsonRepresentation: data)
}
