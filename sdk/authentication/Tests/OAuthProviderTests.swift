//
// Copyright contributors to the IBM Security Verify Authentication SDK for iOS project
//

import XCTest
import Foundation
@testable import Authentication
@testable import Core

class OAuthProviderTest: XCTestCase {
    // TODO: Replace these credential parameters with valid values.
    let clientId = ""
    let clientSecret = ""
    let username = ""
    let password = ""
    let urlBase = "https:sdk.verify.ibm.com/v1.0/endpoint/default"
    
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
        let expectation = XCTestExpectation(description: "Testing \(urlBase)/.well-known/openid-configuration")
        
        let url = URL(string: "\(urlBase)/.well-known/openid-configuration")!
        
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
        let expectation = XCTestExpectation(description: "Testing \(urlBase)/.well-known")
        
        let url = URL(string: "\(urlBase)/.well-known")!
        
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
        let expectation = XCTestExpectation(description: "Testing \(urlBase)/token")
        
        let url = URL(string: "\(urlBase)/token")!
        
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
    
    /// Tests the token endpoint for obtaining an access token and ID token using ROPC.
    func testAuthorizeROPCIDToken() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing \(urlBase)/token")
        
        let url = URL(string: "\(urlBase)/token")!
        
        // Where
        let provider = OAuthProvider(clientId: self.clientId, clientSecret: self.clientSecret, additionalParameters: ["pet": "dog", "food": "pizza"])
        provider.timeoutInterval = 10
       
        provider.authorize(issuer: url, username: self.username, password: self.password, scope: ["openid", "name", "age"]) { result in
            switch result {
            case .success(let value):
                print(value)
                XCTAssertNotNil(value)
                XCTAssertNotNil(value.idToken)
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
        let expectation = XCTestExpectation(description: "Testing \(urlBase)/token")
        
        let url = URL(string: "\(urlBase)/token")!
        
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
        let expectation = XCTestExpectation(description: "Testing \(urlBase)/token")
        
        let url = URL(string: "\(urlBase)/token")!
        
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
    
    /// Tests the token endpoint for obtaining refresh of an access token.
    func testAuthorizeRefresh() throws {
        // Given
        let expectationToken = XCTestExpectation(description: "Testing \(urlBase)/token")
        let url = URL(string: "\(urlBase)/token")!
        
        // Where
        var token: TokenInfo!
        let scopes = ["name", "age"]
        let provider = OAuthProvider(clientId: self.clientId, clientSecret: self.clientSecret, additionalParameters: ["pet": "dog", "food": "pizza"])
        provider.timeoutInterval = 10

        provider.authorize(issuer: url, username: self.username, password: self.password, scope: scopes) { result in
            switch result {
            case .success(let value):
                print(value)
                token = value
                XCTAssertNotNil(value)
            case .failure(let error):
                print(error)
                XCTFail(error.localizedDescription)
            }
            
            expectationToken.fulfill()
        }
        
        // Then
        wait(for: [expectationToken], timeout: 30.0)
        
        // Then
        if token == nil {
            XCTFail("No token was generated by authorization server.")
            return
        }
        
        let expectationRefresh = XCTestExpectation(description: "Testing refresh \(urlBase)/token")
        provider.refresh(issuer: url, refreshToken: token.refreshToken ?? "", scope: scopes) { result in
            switch result {
            case .success(let value):
                print(value)
                XCTAssertNotEqual(value, token)
            case .failure(let error):
                print(error)
                XCTFail(error.localizedDescription)
            }
            
            expectationRefresh.fulfill()
        }
        // Then
        wait(for: [expectationRefresh], timeout: 30.0)
    }
    
    /// Tests the token endpoint for obtaining refresh using an invalid refresh token.
    func testAuthorizeInValidRefreshToken() throws {
        // Given
        let expectationToken = XCTestExpectation(description: "Testing \(urlBase)t/token")
        let expectationRefresh = XCTestExpectation(description: "Testing refresh \(urlBase)/token")
        
        let url = URL(string: "\(urlBase)/token")!
        
        // Where
        let scopes = ["name", "age"]
        let provider = OAuthProvider(clientId: self.clientId, clientSecret: self.clientSecret, additionalParameters: ["pet": "dog", "food": "pizza"])
        provider.timeoutInterval = 10

        provider.authorize(issuer: url, username: self.username, password: self.password, scope: scopes) { result in
            switch result {
            case .success(let value):
                XCTAssertNotNil(value)
            case .failure(let error):
                print(error)
                XCTFail(error.localizedDescription)
            }
            
            expectationToken.fulfill()
        }
        
        // Then
        wait(for: [expectationToken], timeout: 30.0)
        
        // Then
        provider.refresh(issuer: url, refreshToken: "A1b2C3d4", scope: scopes) { result in
            switch result {
            case .success(let value):
                print(value)
                XCTFail()
            case .failure(let error):
                print(error)
                XCTAssertNotNil(error, error.localizedDescription)
            }
            
            expectationRefresh.fulfill()
        }
        // Then
        wait(for: [expectationRefresh], timeout: 30.0)
    }
}

