//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI
import Core

// MARK: Views

/// Presentation of an Medicare proof.
struct MedicareProofRequestView: View {
    @Environment(Model.self) private var model
    
    var jsonRepresentation: Data = Data()
    
    var body: some View {
        let items = displayRequestedClaims()
        List {
            Section(header: Text("Medicare Card")) {
                ForEach(items) { item in
                    LabeledContent(item.id, value: item.value)
                }
            }
        }
    }
}

extension MedicareProofRequestView: ViewDescriptor {
    func displayRequestedClaims() -> [ProofItem] {
        var result: [ProofItem] = []
        
        if let verification = model.verificationGenerated, let info = verification.info, let infoValue = info.value as? [String: Any] {
            // For mdoc and indy we grab the data from "info.attributes".
            if verification.proofRequest.jsonId == nil, let attributes = infoValue["attributes"] as? [[String: Any]] {
                result = attributes.compactMap { item -> ProofItem? in
                    guard let name = item["id"] as? String, let value = item["value"] as? String else {
                        return nil
                    }
                    
                    return ProofItem(id: name, value: value)
                }
            }
        }
        return result
    }
}

/// Presentation of a Government Medicare offer.
struct MedicareCredentialOfferView: View {
    var jsonRepresentation: Data = Data()
    
    /// The credential associated with a Medicare card.
    private var credential: MedicareCredentialOffer {
        let value: MedicareCredentialOffer = formatCredential(using: jsonRepresentation)
        return value
    }
    
    var body: some View {
        List {
            LabeledContent("Card number", value: credential.number)
            LabeledContent("Valid to", value: credential.validTo)
            Section {
                ForEach(credential.holders) { holder in
                    LabeledContent("\(holder.id)", value: "\(holder.fullName)")
                }
            } header: {
                Text("Holders")
            }
        }
    }
}

extension MedicareCredentialOfferView: ViewDescriptor { }

/// Presentation of a Government Medicare card.
struct MedicareCredentialCardView: View {
    var jsonRepresentation: Data = Data()
    
    /// The credential associated with a Medicare card.
    private var credential: MedicareCredentialCard {
        let value: MedicareCredentialCard = formatCredential(using: jsonRepresentation)
        return value
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("medicare")
                    .font(.title2).bold().italic()
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: 150, height: 50)
                    .background(Rectangle()
                        .fill(Color(UIColor(red: 0.1412, green: 0.5412, blue: 0.2392, alpha: 1.0))))
            }
                
            Text(credential.number)
                .font(.title).monospacedDigit()
                .padding()
            ForEach(credential.holders) { holder in
                VStack(alignment: .leading) {
                    HStack{
                        Text("\(holder.id)").monospacedDigit()
                        Text(holder.fullName.uppercased()).monospaced()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Text("VALID TO \(credential.shortValidTo)")
                    .monospaced()
                    .padding(.leading, 64)
                    .padding(.top)
            }
        }
        .padding()
        .background(Color(UIColor(red: 0.60, green: 0.77, blue: 0.54, alpha: 1.00)))
        .cornerRadius(8)
    }
}

extension MedicareCredentialCardView: ViewDescriptor { }


// MARK: Structures

internal struct CardItem: Identifiable, Decodable {
    /// The identifier of the item.
    let id: String
    
    /// The first naem of the item.
    let givenName: String
    
    /// The last name of the item.
    let surname: String
    
    /// The concatenation of the given name and surname.
    var fullName: String {
        get {
            return "\(givenName) \(surname)"
        }
    }
    
    /// The root level JSON structure for decoding.
    private enum CodingKeys: String, CodingKey {
        case id = "irn"
        case givenName = "given_name"
        case surname
    }
}

/// Represents a verifable medicare credntail.
struct MedicareCredentialOffer: Decodable {
    /// The card number.
    let number: String
    
    /// The card validatity date.
    let validTo: String
    
    /// The degree of the holder.
    let holders: [CardItem]
    
    private enum CodingKeys: String, CodingKey {
        case namespaces = "nameSpaces"
    }
    
    private enum NamespacesCodingKeys: String, CodingKey {
        case type = "au.gov.servicesaustralia.medicare.card"
    }
    
    /// The root level JSON structure for decoding.
    private enum TypeCodingKeys: String, CodingKey {
        case number
        case validTo = "valid_to"
        case holders
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let namespaceContainer = try container.nestedContainer(keyedBy: NamespacesCodingKeys.self, forKey: .namespaces)
        let typeContainer = try namespaceContainer.nestedContainer(keyedBy: TypeCodingKeys.self, forKey: .type)
        
        self.number = try typeContainer.decode(String.self, forKey: .number)
        self.validTo = try typeContainer.decode(String.self, forKey: .validTo)
        self.holders = try typeContainer.decode([CardItem].self, forKey: .holders)
    }
}

/// Represents a verifable medicare credntail.
struct MedicareCredentialCard: Decodable {
    /// The card number.
    let number: String
    
    /// The card validatity date.
    let validTo: String

    /// The card validatity style in MM-yyyy format.
    var shortValidTo: String {
        get {
            let inputDateFormatter = DateFormatter()
            inputDateFormatter.dateFormat = "yyyy-MM-dd"
            
            guard let date = inputDateFormatter.date(from: validTo) else {
                return "Unknown"
            }
            
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "MM/yyyy"
            
            return outputDateFormatter.string(from: date)
        }
    }
    
    /// The degree of the holder.
    let holders: [CardItem]
    
    struct AttrributeItem: Decodable {
        let ns: String
        let id: String
        let value: AnyCodable
    }

    /// The root level JSON structure for decoding.
    private enum CodingKeys: String, CodingKey {
        case attributes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let attributes = try container.decode([AttrributeItem].self, forKey: .attributes)
        
        // Find and construct the card information from the attribute.
        guard let item = attributes.first(where: { $0.id == "number"}), let value = item.value.value as? String else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "number not found in payload."))
        }
        self.number = value
        
        guard let item = attributes.first(where: { $0.id == "valid_to"}), let value = item.value.value as? String else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "valid_to not found in payload."))
        }
        self.validTo = value
        
        guard let item = attributes.first(where: { $0.id == "holders"}), let values = item.value.value as? [Any] else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "holders not found in payload."))
        }
        
        var holders: [CardItem] = []
        
        // Easier to loop the [Any] array
        for value in values {
           guard let item = value as? [String: any Any], let id = item["irn"] as? String, let givenName = item["given_name"] as? String, let surname = item["surname"] as? String else {
                continue
            }
            
            holders.append(CardItem(id: id, givenName: givenName, surname: surname))
        }
        
        self.holders = holders
    }
    
    init(number: String, validTo: String, holders: [CardItem]) {
        self.number = number
        self.validTo = validTo
        self.holders = holders
    }
}

// MARK: Previews

#Preview {
    let data = """
{
    "docType": "au.gov.servicesaustralia.medicare.card",
    "nameSpaces": {
        "au.gov.servicesaustralia.medicare.card": {
            "holders": [{
                "irn": "1",
                "given_name": "Jonathan",
                "surname": "Citizen"
            },
            {
                "irn": "2",
                "given_name": "Jane L",
                "surname": "Citizen"
            },
            {
                "irn": "3",
                "given_name": "James A",
                "surname": "Citizen"
            },
            {
                "irn": "4",
                "given_name": "Jill B",
                "surname": "Citizen"
            }],
            "number": "1234567890",
            "valid_to": "2025-09-27"
        }
    }
}
""".data(using: .utf8)!
    MedicareCredentialOfferView(jsonRepresentation: data)
}

#Preview {
    let data = """
{
    "general":{
        "version":"1.0",
        "type":"DeviceResponse",
        "status":0,
        "documents":1
    },
    "validityInfo":{
        "signed":"2024-11-28T23:52:18.000Z",
        "validFrom":"2024-11-28T23:52:18.000Z",
        "validUntil":"2025-11-28T23:52:18.000Z"
    },
    "issuerCertificate":{
        "subjectName":"C=US, CN=2:mso_mdoc:9bc03f5a-0f1d-4f25-a37a-0abe64435004",
        "pem":"-----BEGIN CERTIFICATE-----\nMIIBjjCCAUCgAwIBAgIQD96NHxPvT24O5MTMHtVIPjAFBgMrZXAwRzELMAkGA1UE\nBhMCVVMxODA2BgNVBAMMLzI6bXNvX21kb2M6OWJjMDNmNWEtMGYxZC00ZjI1LWEz\nN2EtMGFiZTY0NDM1MDA0MB4XDTI0MTEyODIzNDcyNloXDTI1MTEyODIzNDcyNlow\nRzELMAkGA1UEBhMCVVMxODA2BgNVBAMMLzI6bXNvX21kb2M6OWJjMDNmNWEtMGYx\nZC00ZjI1LWEzN2EtMGFiZTY0NDM1MDA0MCowBQYDK2VwAyEA7ZDGptUZ7Vdn89An\n6H02rBfnrWpYX3GD7jL9HCAUv7GjQjBAMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0P\nAQH/BAQDAgKEMB0GA1UdDgQWBBTYoAaoZJsaoEg80k7XDF+VQxSYrzAFBgMrZXAD\nQQDFCHufjxNCtuyxQ/EhgvSRT59RCOxbArHaNgf4cQnjgkmZiwPNvMmYElxlawae\ngoCwfcLPZiabD6njeMD4v2kN\n-----END CERTIFICATE-----",
        "notBefore":"2024-11-28T23:47:26.000Z",
        "notAfter":"2025-11-28T23:47:26.000Z",
        "serialNumber":"0fde8d1f13ef4f6e0ee4c4cc1ed5483e",
        "thumbprint":"60a3a27c51dbf4d2db94621e0a4d1aeb320d14a1"
    },
    "issuerSignature":{
        "alg":"EdDSA",
        "isValid":true,
        "reasons":[
        ],
        "digests":{
            "au.gov.servicesaustralia.medicare.card":3
        }
    },
    "deviceKey":{
        "jwk":{
            "crv":"Ed25519",
            "kty":"OKP",
            "x":"5NiE4Re2L8O-KfARTru5pM36Eaf8uz1xwENteBRgp74"
        }
    },
    "dataIntegrity":{
        "disclosedAttributes":"3 of 3",
        "isValid":true,
        "reasons":[
        ]
    },
    "attributes":[{
        "ns":"au.gov.servicesaustralia.medicare.card",
        "id":"holders",
        "value":[{
            "irn": "1",
            "given_name": "Jonathan",
            "surname": "Citizen"
        },
        {
            "irn": "2",
            "given_name": "Jane L",
            "surname": "Citizen"
        },
        {
            "irn": "3",
            "given_name": "James A",
            "surname": "Citizen"
        },
        {
            "irn": "4",
            "given_name": "Jill B",
            "surname": "Citizen"
        }],
        "isValid":true
    },
    {
        "ns":"au.gov.servicesaustralia.medicare.card",
        "id":"number",
        "value":"1234567890",
        "isValid":true
    },
    {
        "ns":"au.gov.servicesaustralia.medicare.card",
        "id":"valid_to",
        "value":"2025-09-27",
        "isValid":true
    }]
}
""".data(using: .utf8)!
    MedicareCredentialCardView(jsonRepresentation: data)
}
