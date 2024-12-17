//
// Copyright contributors to the IBM Verify Digital Credentials Sample App for iOS project
//

import SwiftUI
import Core

// MARK: Views

/// Presentation of an employee proof.
struct EmployeeProofRequestView: View {
    @Environment(Model.self) private var model
    
    var jsonRepresentation: Data = Data()
    var items: [ProofItem] = []
    
    var body: some View {
        let items = displayRequestedClaims()
        List {
            Section(header: Text("Employee Card")) {
                ForEach(items) { item in
                    LabeledContent(item.id, value: item.value)
                }
            }
        }
    }
}

extension EmployeeProofRequestView: ViewDescriptor {
    func displayRequestedClaims() -> [ProofItem] {
        var result: [ProofItem] = []
        
        if let verification = model.verificationGenerated, let info = verification.info, let infoValue = info.value as? [String: Any] {
            // For mdoc and indy we grab the data from "info.attributes".
            if verification.proofRequest.jsonId == nil, let attributes = infoValue["attributes"] as? [[String: Any]] {
                result = attributes.compactMap { item -> ProofItem? in
                    guard let name = item["name"] as? String, let value = item["value"] as? String else {
                        return nil
                    }
                    
                    return ProofItem(id: name, value: value)
                }
            }
        }
        return result
    }
}

/// Presentation of an employee offer.
struct EmployeeCredentialOfferView: View {
    var jsonRepresentation: Data = Data()
    
    /// The credential associated with a employee card.
    private var credential: EmployeeCredential {
        let value: EmployeeCredential = formatCredential(using: jsonRepresentation)
        return value
    }
    
    var body: some View {
        List {
            ForEach(credential.attributes) { item in
                LabeledContent("\(item.name)", value: "\(item.value)")
            }
        }
    }
}

extension EmployeeCredentialOfferView: ViewDescriptor { }

/// Presentation of a employee card.
struct EmployeeCredentialCardView: View {
    var jsonRepresentation: Data = Data()
    
    /// The credential associated with a employee card.
    private var credential: EmployeeCredential {
        formatCredentialCard(using: jsonRepresentation)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Employee Card")
                .font(.title2)
            Spacer()
            ForEach(credential.attributes) { item in
                LabeledContent("\(item.name)", value: "\(item.value)")
            }
        }
        .padding()
        .background(Color(UIColor.systemYellow))
    }
}

extension EmployeeCredentialCardView: ViewDescriptor { }

// MARK: Parse Credential

/// Parse the attributes to format the presentation credential.
func formatCredentialCard(using json: Data) -> EmployeeCredential {
    var attributes: [EmployeeCredential.Attributes] = []
        
    // Convert to dictionary.
    if let dict = try? JSONSerialization.jsonObject(with: json) as? [String: Any] {
        // Find the "values" and resolve the key and "raw" value.
        if let values = dict["values"] as? [String: Any] {
            values.forEach { item in
                if let items = item.value as? [String: Any], let value = items["raw"] as? String {
                    attributes.append(EmployeeCredential.Attributes(name: item.key, value: value))
                }
            }
        }
    }
    
    return EmployeeCredential(attributes: attributes)
}

// MARK: Structure
    
/// Represents a verifable employee credntail.
struct EmployeeCredential: Decodable {
    /// The role of the employee.
    let attributes: [Attributes]

    struct Attributes: Identifiable, Decodable {
        /// Unique identiifer.
        var id = UUID()
        
        /// Name of the attribute.
        let name: String
        
        /// The value of the attribute.
        let value: String
        
        private enum CodingKeys: String, CodingKey {
            case name
            case value
        }
    }
    
    init(attributes: [Attributes]) {
        self.attributes = attributes
    }
}

// MARK: Previews

#Preview {
    let data = """
{
    "schema_id":"8WWveuzx5TX96XcJqbEgTx:2:employee_role:4.2",
    "@type":"https://didcomm.org/issue-credential/1.0/credential-preview",
    "attributes":[{
        "name":"jobTitle",
        "value":"Developer",
        "mime-type":"application/json"
    }]
}
""".data(using: .utf8)!
    EmployeeCredentialOfferView(jsonRepresentation: data)
}

#Preview {
    let data = """
{
    "cred_json": {
        "schema_id": "8WWveuzx5TX96XcJqbEgTx:2:employee_role:4.2",
        "cred_def_id": "8WWveuzx5TX96XcJqbEgTx:3:CL:16:TAG1",
        "rev_reg_id": null,
        "values": {
            "jobTitle": {
                "raw": "Developer",
                "encoded": "28820281878684756005932066005549404492627123131853430506543951015134123902987"
            }
        },
        "signature": {
            "p_credential": {
                "m_2": "80786968821861494527955140233368436045018113895960172751617401275949182537352",
                "a": "38962873580372531160374384564193538396079419034311368056939046016560400240767892621422943342393610197600652334628730524812568730710568837249282080619656569751097215288929454367876718327627802041814189244900831076079373336636993623107110139961092699357069002982483427234718211515340995545638927123852327913495634198081504638582268484828610977996848661064022518097983068873480757653081163515334234809913011918360398593730791599510290520433987498790721759086869612950716846283110217892900671712599764543207157543240947828792482556188746591812877711280296560425803178125794783053861468643625872257054182117152468011157073",
                "e": "259344723055062059907025491480697571938277889515152306249728583105665800713306759149981690559193987143012367913206299323899696942213235956742929972521428046046926544924821774500527",
                "v": "8305316902476096793082057086741914235713580273223095908575375219331189077649217827153825600709002068634688686980625808464615051807870649102445227794223081733964144106962823827875876576462192630223013841544905954382594767583828916471222112143850412441948326723827160580932623961445955455294992910991722746492870950706633710133783901010198606045890671802920704785010427518003062959505280733475453920675737001343108289080272051369332329694978860908910418898951292106376572386334912953611809269681517604277500344010392354050465950978658583397658944606804429755618893580221345615849240181349659448948547720557154240740886893201363522144818697112305140476391070555587972067359312197076426801029848015326962010847659683429390399867552067686798429594544539180484711080706161658998615802643980702158439751814264121080744871354665"
            },
            "r_credential": null
        },
        "signature_correctness_proof": {
            "se": "11500860838721668796987325192538827523228586661607918260285973449249822263554739023897925892233533110740640890148947409323995043881226863232242272146029545473258815128263768546260836116923988747216052054385189583679702282558032827583423869170947717777508452677687909919741252185465192517257578555015385936339047565025165992700241226317712634442494585059749048995062996448724619193883232617831906031320713064737469713311223907794319630133038495008776917162941333510740105031355045595606346219174961560986050849077389437612297778021057725804767778514169268829698510629812118351490489961963726003570396743356163560084852",
            "c": "66481286511676997674594777110888356426031043187629656271276845941391711748411"
        },
        "rev_reg": null,
        "witness": null
    }
}
""".data(using: .utf8)!
    EmployeeCredentialCardView(jsonRepresentation: data)
}
