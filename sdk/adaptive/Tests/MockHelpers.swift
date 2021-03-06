//
// Copyright contributors to the IBM Security Verify Adaptive SDK for iOS project
//

import Foundation
@testable import Adaptive

let trusteerCollection = TrusteerCollectionService(using: "hcu.com", clientId: "hcu.bankingapp", clientKey:  "YMAQAABNFUWS2LKCIVDUSTRAKBKUETCJIMQEWRKZFUWS2LJNBJGUSSKCJFVECTSCM5VXC2DLNFDTS5ZQIJAVCRKGIFAU6Q2BKE4ECTKJJFBEGZ2LINAVCRKBN4VU6ODCGRHGUZD2NZLEYU3PNFTE6VLGBJ4GM322M5FW4NSTMRYFATKMGRLEYZRVNBIEOTTLKRLEW5SXKFRVOMKOGZFHISBQIVSTSNTXOQ3XMTDCGUZUOODUNZEU6TCCLF4FAQKZBJCHCRRSGZGEMQSWPFJDORBZJZRXKRLCG5CHE3SQI43W6RCFMV4VMMCIIVWGOSCUJBVHQRJPPBXGYWTIN44UC33PIN3XONJQHFLXCNSVBJCU6ODEIZGGIV2QLBVHKTJVOFVXUZLKGBRHO4JYG5STSUSPLFDWK52RKREUC2CZJFSUKUDXJM2TC2KKIFDHQRC2G5FFM4JTK5YXITTPBJCHCR3WNZZGCN22NVXDSWKKNFKWU4SPOI4UQQRQN5QXG3TDGJWHCR2TF52GEWTMKBLGS6LNKZHHG2ZZGN4XESCGMJNG43CZJNJEEMTZBJGUC6RRJZGUGV3NGFEHO2RYHBXEEMDEJ5XWYVKFIZWVCSJYGVLXAOLEOU3UWWJVPJUEC2TXNBWVCN2RKIYGK2CWMVGVCQTLFNZXEMDBBI3FCSKEIFIUCQQKFUWS2LJNIVHEIICQKVBEYSKDEBFUKWJNFUWS2LIKAMAAAAAAAAAAAAAAAAAASAAAABZGG2LOM5PWQY3V7IAQAAABAAAAAAIAAAAB2SL4AANAAAAANB2HI4DTHIXS6NBXGMXG4LTUOJ2XG5DFMVZC4Y3PNVKA4AAAJVEUSS3VKFEUEQL2INBUG3RYI5BVG4KHKNEWEM2EKFCUQQLBINBUG3SBIVTWO4DTJVEUSS3BIRBUGQSSHBDUGU3RI5JUSYRTIRIUKSCCOFBUGQSSIF3WOZ2VJVAWORKBJVEUSRSCKFMUUS3PLJEWQ5TDJZAVCY2CJVBHOR2DNFYUOU2JMIZUIUKFJVAVCWLXIRTVCSKIKVEHUYLSFNDDQNKBINAWOZ2BM5EUSRJSJBLFMUKZOV3HE43OHFAWKWBRM5TUGWTGHFNGE6LKLB2HSUTSOFXXUTZPNVCCWYTUKJNHAWTSON3FCVKCORXWQL3SPFBFSVLUJNGVO3LKMRLUCK3OMZ4E6SDQNV2HEVCPJZFHSSKTJBMEY2CUNFSTOWTYJRZUSRCOOAZUG6KEJJZHMM3QKRNEWZKHF54WYSSWNFUDMTDIN5YTS6CRI53FKY2LMFXWO3JZN5KS6UTJGRGFKTSWMU4HI4KOF5QTO2LJPJRHSV3OOJ2DANZRGZGVUOCBGRCUOWDHNJFFUTDOPA2HMY2KJYXTKNBQFNCFGTDUNQ3VIWCCNNKUQYSIJNJEKKZRG5RWEWDFJB3FOTCUG52SWSBTIZSVAN3PNBNDAYLPJZZDAUDNIZCSWODCOVRGGTZSI5DUS3KYIVGUKWDRGNDHGVBTKBHFQ6TFJVXTCZKSK5IWUSSRG4ZUKYKLON4U4RTDMFZUI5TPOVXDSSCPKRJHONDBOA3VGZCXGZSUSUSHIYYW63DRJMXTMYKDGNCDEMDEIJIUURDTIZXXQ3LPGF4WO3RLIJGSWSSNNNJGGNLLJE2WMNTWJJZEMWKIGRDTIOKQOVQTCUBVHBRDMOBSMVJEIN3NMVDE2VBSM5BFMZTZKREG2V2SGIVWIQTQIIVXAL3JGBTESV3NKFLWWMKKN5ZHS5CRJV2W66TDKVAWYSCIMVSUEULONZSEK6TEIVRWE3BWNRTEUK2WJVWVK42CIVGVEZLQJZSTCYKZNV4XAUTTPEZHCTRZJVCEW5K2IFSEWZTNNY4TS6LPJRHHMWDXOR5HO2KSPBMGSYTCNMVXQYLZKVKUUWKVJZAUON2ZKR4VKMCPMRFDORBULBYUG5CWOQ4HGV2NMZ5HIVSMPJ2EMU3SJRITISJRK5CTA2DTLJXDINLNKZGVARSVJBREQVDGJ5LDK532G5JDMSLOMQ2VOQZWKJYWOMDUJJVGWV2OMR3WWMCBMJDVCY2EME4VS4SRNFAWKQ2EIV2WEQTXIFBDKVDIJVRCWU2RGFNDCL3ZM5MFIVBPLJYEE2CCMRYVQM2YNVSHGMDZHBEHSY3BNNEXQM2IKZKGUQSVKJCVSR3YNNHFQQJSOJGTQU3WNU4XMWCMKVLEIRLOONLEU2KZIRLUM3DMIQYES422IZVEE2JYGFKDGSTPK5LWMRKQNRZE2ZDKMNTUOMCQFNBGGTZZF44XQ2CEG4VWYWTQO43VIUZXMVEXKULMKIVXQNCKJNCVS23CNFEEO2DRKR3XUM2QJVKWUODLMF5DMZS2KFRDIUKWIFTG23BVJZ4XSV2QGJEU4MCSNRJVERLYPJVUM3RWPA2UMZDEKJEVSUBYMRYCWZTVJVNEGQ2WPJNHU2KMIR3UI4DINAXSWL3TJFAUSRBVNBUWM4CCKJJHG3DHKQ2GQS2TONAW6OKQO5JGMODROE3UWQSLOZKFSUDGIJXTMRKYOM4TQL3FN53EQSTNOBMU4ULDLBWECV2GNNHVGVTUHBZES4CMONSTOWTLHBXEESSXJBFEUVJXOVEUURKWNBHW2T2LGZRDSQTSI5SC6ZKQJFBXU3KUOVJWGWSYNFGWQSSMPEYGQ4TMM5MESVLDMRUTC23ONRRG2NSJIE2DCUCRNZVXCYKZMFXWW4JRPFUGYRSYOJGUE4ZTM53TKTDMOBKVUOBLOZBGGVDIN5XFKM3ZGJMVUSTNNI2HCVCOGZ3EKTLOGJBFGWT2JB5DQOCSN5YFK2LWJ44USSCFGREFSUSOGJITQZKIJYXUK53INIYGERRSKV3GU5SSNVQWM2KCKNEGCZKIJBTUE5KPGNCUORCWOZBXG2KOORGFKTDLO5SWUZDLOVGWUSSHORDDQ2JZNI2HUSJRN5KFOQZZMFNDI22HKJTDMWSEJN2UM4JUNZ4HKUTDM5DWOQRPKRRW4RBYOF4VSMDYKRGEWK2YPBZDMTDVNNTTSUBUMVSTONCFOMZFQTBXNNRFUR2LONTXCSSCHFCTI3KVNZBEW4ZPG5CFMNTIMNNEGZLVHFYFKZKYLBRG6TRWJZCDMLZLGBSTQNDVN5QXC5CXG5MWGQKDGJCE45SPJBDUWZLBO5KFOU3UJRNEMYSKJ5GUIWTLME3TS23BOREDA4SYJB5DSNCTGM3UITLMGJSUUTSDNVDSW2DUOAZHU2TDON2UONCNMJXTCUTGFM2WK2CBJE2VE3LOMJFXURLSJUZVMRBLNV3UYNLTOZEWQVCRGNZDSTLVOA3UO4SUOF4VAQSYNJ4W6M2XN5YUGUDGHBLGWR3UME3VIVTWLA4W4Z2FFMZHK33CKBSHOTDJHBMG25C2ON2FO4KBKJYXAS3BGNUFIVBYM5AVEQJRKV3WU6KRMNTS6RLZLJ3TCULQIJQXUZTMNA2C63ZYLBUWE4RZNIZEUZCGKF2VIVCQOZRG2MKVKVZFCWLTNY2HO2RSJNVWCMDLIE4TG3SMOQ3U2NTQHFKTOQJVNBDWQ5LENNEHQS2CLF5DI5SEM5FDM23XJJFUUNBXHB2WG4COKAYS6VD2IVTEW4CDNZGHKMSMJZWHQUDTIVAXG3CSMJEW6RSSLJDUIV3YMRQTQULHMFKTKUKEO5TGITDYN5ESWTBSMFBHU6JLINCW24JXKEYGU6BZI5FXMWDFMZUS643XM5TVMQSCM5VXC2DLNFDTS5ZQIJBHOR3HM5TVK6KCJFEUMTDKINBUEU3PO5TWOVLNIJTXG4LINNUUOOLXGBBEIQLPIJAXCQ2DIJHTI53HM5KHCTKCO5DUG2LRI5JUSYRTIRIUKTKBKFGXORDHKFEUM2JTNJFFU3BRKBGGWQ2BM5TUCQSJJFCXSTKJLF2WOSKYJRVVE33QLJUVE33FKRVUWUSLGJEXI2SBJ5CGE6BVJBVWIYLENUVTSZ3TONTWEMRVNJAWIRKXJEYDS6SVG4XUY5COMVNGWN2DMJMGM3CUJFDU6SKGIU2XCR3DG5HFCSTLIJMU2QTUPF3EOTDWJZ2TQVTLN53DALZTGRYXSNSUNBIXMUCROF4EIUZQGI2G42KNNVQUU4THPJEDE6SIGMYVK2SSIRATSU3VIVJFKKZPKA3TO3CDMJCFQYLOHFWHI3DSKNMUYTSCHF5HKUSYLBIXMSRQGR2VI6TCOFJTGULKJFKU6S2GGU4G43TMHFXHAN3QINVDIWKVNNWVAMDSM5DUQTRWKQ2WYRTDKJXUIMSYMNXXS4LVOZTWKRBXGQ2UOU3UPI3G6TCRGBJFKSZZM5GUKMCVIZ3VUNRPPI2VCSTVNZATG53IPFVHM4RZJR4TM2L2IJYDCOKKIVLSWWTPGUYFANTBJRFS64CNI5LDA3KYNQ4E653TIZDW6SSUKBXVEYTPJNXVGQ3IORTFITDLGRIFS5BSMVTG22SZKZRXKNBPFNVTKTBQNVAVMURYGBQW6S3OHB5GKWDMI42GQVSTF4ZEI5JZOFBHONSPPFIGCRZRINCU6TDPNFDHA6RRM5CVEVDTKVZVO3T2KVIECKZTK5DVMRDNGVLS6WCFNRQUYZLHMFVTSMSDJF4E4TDDKRNEOUDQIVCEWVSTINXDMTBVIFHGG6TQNFFCWQKMIJZTST3DF4VXAWSLKVMEQUCQMVSUGVZPJ5EXA6KONRWSWWKHIVDG2R3FON3U24LGLE3DCNSQOVMFEQ3NLFZUG22RMVBGSMKIMZVDATCDPJJESOK2NNFUU2COIJUEUNCLJBCGE6TSLA2TEYTKNVSUWQRRIVDFI42UHE2G4Y2ZGRTVCVSPMN3GI3LINNUFOVSZJNCHQ42TOBXG63SZJB2GQSS2IZWUYZ3PNJ2WS4KLOJKGE3SJIJZXGTTJNRIXAWDYIJVEMZTRM5SGUTLHJFYEC22BJVHHEWSMO5UUON3MGV3UMT3GNJWVGNTKIMYGYUKTOY2EOYTINA3UE3KLKFZXK3KEKQ2UUMDYMNDUYSKTLAZVEY3XO5UU6MRRGMZFOSCPNFTU6WBXGJYGCT2XLBDS64SGINJWMNTKMZWFOMJUNVAXC6KFK5HHISLWKRJU24TXKBRVK6RPGVCGW33BONFXU3ZLLF3HCNKWOJ2EUVCRNVRFCQSQKVHWIUT2HB5GWMKLJB2XA6SBJYZEGMLIKVUDS4CJO5RWC33QJAYECWCPINKTS5KFG4VUU2DCGA4EWNBLONEUIWDRORHGCYLJNV3W44ZQPBHHQUTSOFGFKK3WNZMDMSSOLBUWEN2MKN2VK42VPJCXK5SRGFLEO3DJIMZUGWCMNJVESQ2CGR4XUYTQMFVFMV3BGVBESTKOJFIUYZ3CM5HDM5LHJR2WUODINE4WYQKGN5FWEQ3TNRRVC32GKUZWMTLNJFJHGOJVIRUUWVKJMRLGKTKFNNFEYUZXMJWWU4KNKVLG422JOFJUOQTGJZHDCSJRLEYUYMCCGE3TMT3DJRWUK3LZJJ5DA2TCKQ2GU23IGZWGG4KBOJ4WO53BLF2XG3CYJ5KGOMLIKN3VM6LQIR2WESLSONHXGVTKGZAVC5JQGBMFESDKO5DC642KF5KWYYKTMFJHK5RYKJFHKUDENZQUQ5RXOMZGONKDNFDWO43SNNXVG2TJINUVG3ZQOB2GYSJLIFDEIK3HONITSRLTG5XEKWLXF55EOTLWMFATK5TOMRQVSWCZNNKUQ4SVKZJFIUKLNFIGSK3OJBLFS2CTNZBEEWSJF55FAT3LGRWXAQKVNE3DKZTHLJFXQQ2ONQ4DGT2JJBMU6VRTHFYFCN3QGJMHKZ2ONZTHG33QPJYXAU2YI5VHC6RTMVLDQK2FG5CVI33IJJQVA3CRORUFC6TMKFEHOUDHGY2E6T2QGBXSWQ32IN2FKY2CMRMFMYSUGVVTMWKMPB3WOY3WGFWE25CKNNKUE5CPLJHXMVLULBRXQQ2GJJGFS4DEFNRTS4SUOA2DMZDSJV4TO4CNJIYU2RC2K53FA4SVKNUHUNJQGJBHMVLLIZMHGUTWJNMU4TCMPFAWESBTIRHWEMCFJM2HEVTYJBWWC22VMRWWONKNGZLTQ6D2NNIG4SBVGUYUYT3TJVJEEMZSKJDDEMBUF5CEONLVKR4WQ2CHGVBFETSSFN2E6K2OLEZUI4TIORGU4K32GRSGUZDCLJGXQ4SIF5ZWOZCLNJGUUZSZM5EUK2KPKEZFQTRWJRMG62TEMNCXAUZZIRCFOZLBKBZWQVKGGNTUQODDLBYGSZ2VONZHO2BWIFMGQMBVLEXWKMBSJUZU26CKINRGOLZTMZLGE5KVNJUUCSLJKRZDAUSQOR4EIMJZJVCWUR2PKY2HSU3MJREUMNSSMQ3U6N2TNJCTC33FJQ2WWNDLJNDWEWJZKM4XCYTINBKEI4RXGJWEYZSBGZBVKNKNM54G4S2HKJKUQQSIOV5DGYLCOFFFOWCYPFSFSOCJIJKUEZTOGF2GS6SGIVRWOOKQPB2FUM2ZOJTGUQRXGJUGOK3YJNZDSK2FIRCWYTKDJVDUGU3RI5JUSYRTIRIUKSSGKRCVOQSCKRNFGZCSMZZFM3SNLJBDOOBTGZDHIMSWNBSGI3ZXIFZEIQLYJVBUK52DKFMUMS3XGRCEC2DPIZAUCUKVIRTTAOC2GQ2DM6TLGB2WWUBVKJWGM6CLFNZXA3K2NBTUKQ2KIJBFCQTEF5HGQMKCIFTUSSKBIE6T2WIWQDHETIGFEASEV6ZCNC4JULI")

/// A convenience enum to support different adaptive tests.
enum MockAdaptiveTestType : Int {
    case allow = 0
    case deny
    case requiresEnrolled
    case requiresAllowed
    case random
}

/// A mock result.
struct MockAdaptiveServiceResult: Decodable {
    var status: String
    var token: String?
    var factors: [AssessmentFactor]?
    var transactionId: String?
    
    /// The root level JSON structure for decoding.
    private enum CodingKeys: String, CodingKey {
        case status
        case token
        case allowedFactors
        case enrolledFactors
        case transactionId
    }

    /// Creates a new instance by decoding from the given decoder
    /// - parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Status
        self.status = try container.decode(String.self, forKey: .status)
        
        // Requires or Allow
        if self.status == AssessmentStatusType.requires {
            // Check what type of assessment factor we need to decode.
            if container.contains(.allowedFactors) {
                self.factors = try container.decode([AllowedFactor].self, forKey: .allowedFactors)
            }
            
            if container.contains(.enrolledFactors) {
                self.factors = try container.decode([EnrolledFactor].self, forKey: .enrolledFactors)
            }
            
            self.transactionId = try container.decodeIfPresent(String.self, forKey: .transactionId)
        }
        else if self.status == AssessmentStatusType.allow {
            self.token = nil
            
            // The token will end up being decoded as a dictionary.
            guard let result = try container.decodeIfPresent(Dictionary<String, Any>.self, forKey: .token) else {
                return
            }
            
            
            // Convert the dictionary of [String: Any] back to a JSON string.
            if let data = try? JSONSerialization.data(withJSONObject: result,
                options: []) {
                self.token = String(data: data, encoding: .utf8)
            }
        }
    }
}

public struct AnyDecodable: Decodable {
    public var value: Any

    private struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
    
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            var result = [String: Any]()
            try container.allKeys.forEach { key throws in
                result[key.stringValue] = try container.decode(AnyDecodable.self, forKey: key).value
            }
            value = result
        }
        else if var container = try? decoder.unkeyedContainer() {
            var result = [Any]()
            while !container.isAtEnd {
                result.append(try container.decode(AnyDecodable.self).value)
            }
            value = result
        }
        else if let container = try? decoder.singleValueContainer() {
            if let intVal = try? container.decode(Int.self) {
                value = intVal
            }
            else if let doubleVal = try? container.decode(Double.self) {
                value = doubleVal
            }
            else if let boolVal = try? container.decode(Bool.self) {
                value = boolVal
            }
            else if let stringVal = try? container.decode(String.self) {
                value = stringVal
            }
            else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing serialisable")
            }
        }
        else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not serialise"))
        }
    }
}
