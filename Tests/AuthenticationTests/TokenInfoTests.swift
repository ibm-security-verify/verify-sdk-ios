//
// Copyright contributors to the IBM Security Verify Authentication SDK for iOS project
//

import XCTest
import Foundation
@testable import Authentication

class TokenInfoTests: XCTestCase {
    let urlBase = "https://sdk.verify.ibm.com/v1.0/endpoint/default/token"
    
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockURLProtocol.self)
    }

    override func tearDown() {
        super.tearDown()
        URLProtocol.unregisterClass(MockURLProtocol.self)
    }

    /// Decodes the `TokenInfo`
    func testDecodeTokenExpiresIn() throws {
        // Given
        let decoder = JSONDecoder()
        
        // Where
        let token = try decoder.decode(TokenInfo.self, from: tokenJson.data(using: .utf8)!)
        
        // Then
        XCTAssertNotNil(token, "Decoded token success")
        XCTAssertEqual(token.accessToken, "a1b2c3d4")
        XCTAssertEqual(token.refreshToken, "h5j6i7k8")
        XCTAssertEqual(token.expiresIn, 7200)
        XCTAssertEqual(token.scope, "name age")
    }
    
    /// Decodes the `TokenInfo`
    func testDecodeTokenExpires_In() throws {
        // Given
        let decoder = JSONDecoder()
        
        // Where
        let token = try decoder.decode(TokenInfo.self, from: tokenJson2.data(using: .utf8)!)
        
        // Then
        XCTAssertNotNil(token, "Decoded token success")
        XCTAssertEqual(token.accessToken, "a1b2c3d4")
        XCTAssertEqual(token.refreshToken, "h5j6i7k8")
        XCTAssertEqual(token.expiresIn, 7200)
        XCTAssertEqual(token.scope, "name age")
    }
    
    /// Decodes the `TokenInfo` and checks the `expiresIn`.
    func testTokenExpired() throws {
        // Given
        let decoder = JSONDecoder()
        
        // Where
        let token = try decoder.decode(TokenInfo.self, from: tokenJson.data(using: .utf8)!)
        
        // Then
        XCTAssertNotNil(token, "Decoded token success")
        XCTAssertTrue(token.tokenExpired)
    }
    
    /// Decodes the `TokenInfo` and checks the `shoudRefresh`.
    func testTokenShouldRefresh() throws {
        // Given
        let decoder = JSONDecoder()
        
        // Where
        let token = try decoder.decode(TokenInfo.self, from: tokenJson.data(using: .utf8)!)
        
        // Then
        XCTAssertNotNil(token, "Decoded token success")
        XCTAssertTrue(token.shouldRefresh)
    }
    
    /// Decodes the `TokenInfo` twice and checks to equality.
    func testTokenIsEqual() throws {
        // Given
        let decoder = JSONDecoder()
        
        // Where
        let token1 = try decoder.decode(TokenInfo.self, from: tokenJson.data(using: .utf8)!)
        let token2 = try decoder.decode(TokenInfo.self, from: tokenJson.data(using: .utf8)!)
        
        // Then
        XCTAssertEqual(token1, token2)
    }
    
    /// Decodes the `TokenInfo` and create the request authorization header value.
    func testTokenHeader() throws {
        // Given
        let decoder = JSONDecoder()
        let headerValue = "Bearer a1b2c3d4"
        
        // Where
        let token = try decoder.decode(TokenInfo.self, from: tokenJson.data(using: .utf8)!)
        
        // Then
        XCTAssertNotNil(token, "Decoded token success")
        XCTAssertEqual(token.authorizationHeader, headerValue)
    }


    /// Encodes the `TokenInfo`.
    func testEncodeToken() async throws {
        // Given
        let tokenUrl = URL(string: urlBase)!
        MockURLProtocol.urls[tokenUrl] = MockResponse(response: HTTPURLResponse(url: tokenUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!, data: tokenJson.data(using: .utf8)!)
        
        // Where
        var token: TokenInfo?
        let provider = OAuthProvider(clientId: "clientId", clientSecret: "clientSecret", additionalParameters: ["pet": "dog", "food": "pizza"])
        provider.timeoutInterval = 10
       
        // Then
        do {
            token = try await provider.authorize(issuer: tokenUrl, username: "username", password: "password", scope: ["name", "age"])
                XCTAssertNotNil(token)
        }
        catch let error {
            print(error)
            XCTFail(error.localizedDescription)
        }
        
        // Then
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(token)
        print(String(data: data, encoding: .utf8)!)
    }
}


let tokenJson = """
{
  "token_type" : "Bearer",
  "scope" : "name age",
  "refreshToken" : "h5j6i7k8",
  "grant_id" : "b49cf0c8add0",
  "accessToken" : "a1b2c3d4",
  "expires_on" : 676711055.01398504,
  "expiresIn" : 7200
}
"""

let tokenJson2 = """
{
  "token_type" : "Bearer",
  "scope" : "name age",
  "refreshToken" : "h5j6i7k8",
  "grant_id" : "b49cf0c8add0",
  "accessToken" : "a1b2c3d4",
  "expires_on" : 676711055.01398504,
  "expires_in" : 7200
}
"""
