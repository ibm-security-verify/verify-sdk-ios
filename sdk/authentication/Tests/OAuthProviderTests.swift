//
// Copyright contributors to the IBM Security Verify Authentication SDK for iOS project
//

import XCTest
import Foundation
import AuthenticationServices
@testable import Authentication
@testable import Core

class OAuthProviderTest: XCTestCase {
    let clientId = "38cdeff8-9693-4f0b-99c9-563d5c20d6a7"
    let clientSecret = "MFbkXzPBpE"
    let username = "testuser"
    let password = "Passw0rd"
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Discovery
    
    /// Tests the disovery endpoint against a publically OAuth 2 endpoint.
    func testDiscover() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://sdk.verify.ibm.com/v1.0/endpoint/default/.well-known/openid-configuration")
        
        let url = URL(string: "https://sdk.verify.ibm.com/v1.0/endpoint/default/.well-known/openid-configuration")!
        
        // Where
        OAuthProvider.discover(issuer: url) { result in
            switch result {
            case .success(_):
                XCTAssert(true)
            case .failure(let error):
                print(error)
                XCTFail(error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testInvalidDiscover() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://sdk.verify.ibm.com/v1.0/endpoint/default/.well-known")
        
        let url = URL(string: "https://sdk.verify.ibm.com/v1.0/endpoint/default/.well-known")!
        
        // Where
        OAuthProvider.discover(issuer: url) { result in
            switch result {
            case .success(_):
                XCTFail("The .well-known endpoint metadata shouldn't be returned.")
            case .failure(let error):
                print(error)
                XCTAssertNotNil(error)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }

    // MARK: - Authorize
    
    /// Tests the token endpoint for obtaining an access token using ROPC.
    func testAuthorizeROPC() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://sdk.verify.ibm.com/v1.0/endpoint/default/token")
        
        let url = URL(string: "https://sdk.verify.ibm.com/v1.0/endpoint/default/token")!
        
        // Where
        let provider = OAuthProvider(clientId: self.clientId, clientSecret: self.clientSecret, additionalParameters: ["pet": "dog", "food": "pizza"])
        provider.timeoutInterval = 10
       
        provider.authorize(issuer: url, username: self.username, password: self.password, scope: ["name", "age"]) { result in
            switch result {
            case .success(let value):
                print(value)
                XCTAssertNotNil(value)
            case .failure(let error):
                print(error)
                XCTFail(error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    /// Tests the token endpoint for obtaining an access token using ROPC which generates a grant_id
    func testAuthorizeWithParametersResponse() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://sdk.verify.ibm.com/v1.0/endpoint/default/token")
        
        let url = URL(string: "https://sdk.verify.ibm.com/v1.0/endpoint/default/token")!
        
        // Where
        let provider = OAuthProvider(clientId: self.clientId, clientSecret: self.clientSecret)
        provider.timeoutInterval = 10
       
        provider.authorize(issuer: url, username: self.username, password: self.password) { result in
            switch result {
            case .success(let value):
                print(value)
                XCTAssertNotNil(value)
                XCTAssertNotNil(value.additionalData)
                XCTAssertTrue(value.additionalData.contains { return $0.key == "grant_id" })
            case .failure(let error):
                print(error)
                XCTFail(error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    /// Tests the token endpoint for obtaining an access token using ROPC.
    func testAuthorizeWithScope() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://sdk.verify.ibm.com/v1.0/endpoint/default/token")
        
        let url = URL(string: "https://sdk.verify.ibm.com/v1.0/endpoint/default/token")!
        
        // Where
        let provider = OAuthProvider(clientId: self.clientId, clientSecret: self.clientSecret)
        provider.timeoutInterval = 10
       
        provider.authorize(issuer: url, username: self.username, password: self.password, scope: ["name", "age"]) { result in
            switch result {
            case .success(let value):
                XCTAssertNotNil(value)
                XCTAssertNotNil(value.scope)
                XCTAssertEqual(value.scope, "name age")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
}


import Authentication           // IBM Verify Authentication SDK
import AuthenticationServices   // Apple Authentication SDK

class AuthenticateViewController: UIViewController {
    func onLoginClick() {
        let provider = OAuthProvider(clientId: "abc123")
        provider.delegate = self
        
        provider.authorizeWithBrowser(issuer: URL(string: "https://myidp.com/authorize")!, redirectUrl: URL(string: "myapp://callback")!, presentingViewController: self)   // The redirect is registered with the IDP.
    }
}

extension AuthenticateViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

extension AuthenticateViewController: OAuthProviderDelegate {
    func oauthProvider(provider: OAuthProvider, didCompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func oauthProvider(provider: OAuthProvider, didCompleteWithCode result: (code: String, state: String?)) {
        provider.authorize(issuer: URL(string: "https://myidp.com/token")!, authorizationCode: result.code, codeVerifier: nil, scope: nil) { result in
         
            switch result {
            case .success(let token):
                print("save \(token)")
            case .failure(let error):
                print("error \(error.localizedDescription)")
            }
        }
    }
}

