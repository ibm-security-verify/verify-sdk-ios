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
        let result = try DPoP.generateProof(key, uri: "https://server.com")
        
        // Then
        XCTAssertTrue(!result.isEmpty)
    }
    
    // Test generating a DPoP proof with access token.
    func testGenarateProofWithAccessToken() throws {
        // Given
        let key = RSA.Signing.PrivateKey()
        
        // Where
        let result = try DPoP.generateProof(key, uri: "https://example.com", accessToken: "abc123")
        
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
            let _ = try DPoP.generateProof(key, algorithm: Insecure.SHA1(), uri: "example.com")
        }
        catch let error {
            XCTAssertNotNil(error, error.localizedDescription)
        }
    }
}
