//
// Copyright contributors to the IBM Security Verify Authentication SDK for iOS project
//

import XCTest
import Core
@testable import Authentication
import CryptoKit


class DPoPHelperTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Test generating a DPoP proof.
    func testGenarateProof() throws {
        // Given
        let key = RSA.Signing.PrivateKey()
        
        // Where
        let result = try DPoP.generateProof(key, uri: "https://sdk.verify.ibm.com/oauth2/token")
        print(result)
        
        // Then
        XCTAssertTrue(!result.isEmpty)
    }
    
    // Test generating a DPoP proof using a POST and GET with the same private key.
    func testGenarateProof2() async throws {
        // Given
        let key = RSA.Signing.PrivateKey()
        var accessToken = ""
        var parameters: [String: Any] = ["grant_type": "client_credentials",
                          "client_id": "df3ede58-19fb-45d4-a5ca-f0e82b4e569f",
                          "client_secret": "Z91m00KQeC"]
        
        let body = urlEncode(from: parameters).data(using: .utf8)!
        
        // Where
        // Generate the request for a DPoP access token
        let resource = HTTPResource<TokenInfo>(json: .post,
                                               url: URL(string: "https://sdk.verify.ibm.com/oauth2/token")!,
                                               contentType: .urlEncoded,
                                               body: body,
                                               headers: ["DPoP": try DPoP.generateProof(key, uri: "https://sdk.verify.ibm.com/oauth2/token")],
                                               timeOutInterval: 30)
        
        let token = try await URLSession(configuration: .default).dataTask(for: resource)
        print(token)
        XCTAssertNotNil(token)
        
        // Then
        // Generate the DPoP JWT for introspection
        let result = try DPoP.generateProof(key, uri: "http://localhost:8080/validate-token", method: .get, accessToken: token.accessToken)
        print(result)
        
        // Then
        XCTAssertTrue(!result.isEmpty)
    }
    
    // Test generating a DPoP proof with access token.
    func testGenarateProofWithAccessToken() throws {
        // Given
        let key = RSA.Signing.PrivateKey()
        
        // Where
        let result = try DPoP.generateProof(key, uri: "http://localhost:8080/validate-token", method: .get, accessToken: "yFaQY5OKvYJ06b4p8hF3HJgrYjWKR_wIF2o-_RPz8hU.Kipym-vjiE9J80K4TVvKSoc7gbQnkUkgbziSku9-zC0Aeur8dYoaYLZlE0oaDL2ohh8k6qZ47hNQsM-0rB2nCw.M18xNjk4NzExMTk1XzQ0")
        print(result)
        
        // Then
        XCTAssertTrue(!result.isEmpty)
    }
    
    // Test generating a DPoP proof with a HTTP GET method.
    func testGenarateProofWithGetMethod() throws {
        // Given
        let key = RSA.Signing.PrivateKey()
        
        // Where
        let result = try DPoP.generateProof(key, uri: "https://example.com", method: .get)
        print(result)
        
        // Then
        XCTAssertTrue(!result.isEmpty)
    }
    
    // Test generating a DPoP proof with invalid url.
    func testGenarateProofInvalidURL() throws {
        // Given
        let key = RSA.Signing.PrivateKey()
        
        // Where, Them
        do {
            let _ = try DPoP.generateProof(key, uri: "")
        }
        catch let error {
            XCTAssertNotNil(error, error.localizedDescription)
        }
    }
    
    // Test generating a DPoP proof with invalid hash.
    func testGenarateProofInvalidHash() throws {
        // Given
        let key = RSA.Signing.PrivateKey()
        
        // Where, Them
        do {
            let _ = try DPoP.generateProof(key, hashAlgorithm: Insecure.SHA1(), uri: "https://example.com")
        }
        catch let error {
            XCTAssertNotNil(error, error.localizedDescription)
        }
    }
    
    // Test generating a DPoP proof with SHA384 hash.
    func testGenarateProofSHA384Hash() throws {
        // Given
        let key = RSA.Signing.PrivateKey()
        
        // Where, Them
        do {
            let _ = try DPoP.generateProof(key, hashAlgorithm: SHA384(), uri: "https://example.com")
        }
        catch let error {
            XCTAssertNotNil(error, error.localizedDescription)
        }
    }
    
    // Test generating a DPoP proof with SHA512 hash.
    func testGenarateProofSHA512Hash() throws {
        // Given
        let key = RSA.Signing.PrivateKey()
        
        // Where, Them
        do {
            let _ = try DPoP.generateProof(key, hashAlgorithm: SHA512(), uri: "https://example.com")
        }
        catch let error {
            XCTAssertNotNil(error, error.localizedDescription)
        }
    }
}
