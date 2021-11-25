//
// Copyright contributors to the IBM Security Verify Core SDK for iOS project
//

import XCTest
@testable import Core

class KeychainServiceTests: XCTestCase {
    
    struct Person: Codable {
        var name: String
        var age: Int
        var acive: Bool
        var createdDate: Date
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - Add Tests
    
    /// Adds  `Data` then removes the keychain item.
    func testAddAndDeleteItemData() throws {
        // Given
        var result = true
        
        // When
        do {
            try KeychainService.default.addItem("greeting", value: "Hello World".data(using: .utf8)!)
            try KeychainService.default.deleteItem("greeting")
        }
        catch {
            result = false
        }
        
        // Then
        XCTAssertTrue(result)
    }

    /// Adds a `String` then removes the keychain item.
    func testAddAndDeleteItemString() throws {
        // Given
        var result = true
        
        // When
        do {
            try KeychainService.default.addItem("greeting", value: "Hello World")
            try KeychainService.default.deleteItem("greeting")
        }
        catch {
            result = false
        }
        
        // Then
        XCTAssertTrue(result)
    }
    
    /// Adds a `String` with access control of `.userPresence`.
    func testAddAndDeleteItemStringWithUserPresense() throws {
        // Given
        var result = true

        // When
        do {
            try KeychainService.default.addItem("greeting", value: "Hello World", accessControl: .userPresence)
        }
        catch {
            result = false
        }
        
        // Then
        try KeychainService.default.deleteItem("greeting")
        
        // Then
        XCTAssertTrue(result)
    }
    
    /// Adds a `String` with access control of `.biometryCurrentSet`.
    func testAddAndDeleteItemStringWithBiometryCurrentSet() throws {
        // Given
        var result = true

        // When
        do {
            try KeychainService.default.addItem("greeting", value: "Hello World", accessControl: .biometryCurrentSet)
        }
        catch {
            result = false
        }
        
        // Then
        try KeychainService.default.deleteItem("greeting")
        
        // Then
        XCTAssertTrue(result)
    }
    
    /// Adds a `String` with access control of `.biometryAny`.
    func testAddAndDeleteItemStringWithBiometryAny() throws {
        // Given
        var result = true

        // When
        do {
            try KeychainService.default.addItem("greeting", value: "Hello World", accessControl: .biometryAny)
        }
        catch {
            result = false
        }
        
        // Then
        try KeychainService.default.deleteItem("greeting")
        
        // Then
        XCTAssertTrue(result)
    }
    
    /// Adds a `String` with access control of `.devicePasscode`.
    func testAddAndDeleteItemStringWithDevicePasscode() throws {
        // Given
        var result = true

        // When
        do {
            try KeychainService.default.addItem("greeting", value: "Hello World", accessControl: .devicePasscode)
        }
        catch {
            result = false
        }
        
        // Then
        try KeychainService.default.deleteItem("greeting")
        
        // Then
        XCTAssertTrue(result)
    }
    
    /// Adds, then deletes a `struct`.
    func testAddAndDeleteItemStrut() throws {
        // Given
        var result = true
        let person = Person(name: "John Doe", age: 32, acive: true, createdDate: Date())
    

        // When
        do {
            try KeychainService.default.addItem("account", value: person)
            try KeychainService.default.deleteItem("account")
        }
        catch {
            result = false
        }
        
        // Then
        XCTAssertTrue(result)
    }
    
    /// Adds, then deletes a `Bool`.
    func testAddAndDeleteItemBool() throws {
        // Given
        var result = true
       
        // When
        do {
            try KeychainService.default.addItem("active", value: false)
            try KeychainService.default.deleteItem("active")
        }
        catch {
            result = false
        }
        
        // Then
        XCTAssertTrue(result)
    }
    
    /// Adds, then deletes a `Double`.
    func testAddAndDeleteItemDouble() throws {
        // Given
        var result = true
       
        // When
        do {
            try KeychainService.default.addItem("amount", value: 123.456)
            try KeychainService.default.deleteItem("amount")
        }
        catch {
            result = false
        }
        
        // Then
        XCTAssertTrue(result)
    }
    
    /// Adds, then deletes a `Date`.
    func testAddAndDeleteItemDate() throws {
        // Given
        var result = true
       
        // When
        do {
            try KeychainService.default.addItem("createdDate", value: Date())
            try KeychainService.default.deleteItem("createdDate")
        }
        catch {
            result = false
        }
        
        // Then
        XCTAssertTrue(result)
    }
    
    /// Fails to add a keychain item, throwing an `invalidKey` error.
    func testAddItemInvalidKey() throws {
        // Given
        var thrownError: Error?

        // When
        XCTAssertThrowsError(try KeychainService.default.addItem("", value: "Hello World")) {
            thrownError = $0
        }

        // Then
        XCTAssertTrue(thrownError is KeychainError, "Unexpected error type: \(type(of: thrownError))")

        // Then
        XCTAssertEqual(thrownError as? KeychainError, .invalidKey)
    }
    
    /// Attempts to add a duplicate key throwing `duplicateKey` error.
    func testAddItemDuplicatedKey() throws {
        // Given
        var thrownError: Error?

        // When
        try? KeychainService.default.addItem("greeting", value: "Hello World")
        
        // When
        XCTAssertThrowsError(try KeychainService.default.addItem("greeting", value: "Hello World")) {
            thrownError = $0
        }

        // Then
        XCTAssertTrue(thrownError is KeychainError, "Unexpected error type: \(type(of: thrownError))")

        // Then
        XCTAssertEqual(thrownError as? KeychainError, .duplicateKey)
    }
    
    
    // MARK: - Read Tests
    
    /// Adds, read then deletes a `Double`.
    func testAddReadAndDeleteItemDouble() throws {
        // Given
        var result: Double = 0
        let value = 123.456
       
        // When
        do {
            try KeychainService.default.addItem("amount", value: value)
            
            result = try KeychainService.default.readItem("amount", typeof: Double.self)
            
            try KeychainService.default.deleteItem("amount")
        }
        catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // Then
        XCTAssertEqual(value, result)
    }
    
    /// Adds, read then deletes a `String`.
    func testAddReadAndDeleteItemString() throws {
        // Given
        var result = ""
        let value = "Hello world"
       
        // When
        do {
            try KeychainService.default.addItem("greeting", value: value)
            
            result = try KeychainService.default.readItem("greeting", typeof: String.self)
            
            try KeychainService.default.deleteItem("greeting")
        }
        catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // Then
        XCTAssertEqual(value, result)
    }
    
    /// Adds, read then deletes a `Struct`.
    func testAddReadAndDeleteItemStruct() throws {
        // Given
        var result: Person?
        let value = Person(name: "John Doe", age: 32, acive: true, createdDate: Date())
       
        // When
        do {
            try KeychainService.default.addItem("account", value: value)
            
            result = try KeychainService.default.readItem("account", typeof: Person.self)
            
            try KeychainService.default.deleteItem("account")
        }
        catch let error {
            XCTFail(error.localizedDescription)
        }
        
        // Then
        XCTAssertEqual(value.name, result!.name)
    }
    
    /// Adds, read then deletes failig on the decoding.
    func testAddReadDeleateDecodeFail() throws {
        // Given
        var thrownError: Error?
        let value = Person(name: "John Doe", age: 32, acive: true, createdDate: Date())
       
        // When
        try KeychainService.default.addItem("account", value: value)
        
        // When
        XCTAssertThrowsError(try KeychainService.default.readItem("account", typeof: String.self)) {
            thrownError = $0
        }
     
        // Then
        XCTAssertTrue(thrownError is KeychainError, "Unexpected error type: \(type(of: thrownError))")

        // Then
        XCTAssertEqual(thrownError as? KeychainError, .unexpectedData)
        
        // Then
        try KeychainService.default.deleteItem("account")
    }
    
    
    // MARK: - Delete Tests
    
    /// Fails to delete a keychain item, throwing an `invalidKey` error.
    func testDeleteItemInvalidKey() throws {
        // Given
        var thrownError: Error?

        // When
        XCTAssertThrowsError(try KeychainService.default.deleteItem("")) {
            thrownError = $0
        }
        
        // Then
        XCTAssertTrue(thrownError is KeychainError, "Unexpected error type: \(type(of: thrownError))")

        // Then
        XCTAssertEqual(thrownError as? KeychainError, .invalidKey)
    }
    
    /// Delete a keychain item and only throws an error on an unhandled exception occuring in the SecKey methods.
    func testDeleteItem() throws {
        // Given
        var result = true
        
        // When
        do {
            try KeychainService.default.deleteItem("greeting")
        }
        catch {
            result = false
        }
        
        // Then
        XCTAssertTrue(result)
    }
    
    // MARK: - Exists Test
    /// Adds a `String`, queries for the key, then delete.
    func testAddExistsThenDelete() throws {
        // Given
        var result = true

        // When
        do {
            try KeychainService.default.addItem("greeting", value: "Hello World")
            result = KeychainService.default.itemExists("greeting")
        }
        catch {
            result = false
        }
        
        // Then
        try KeychainService.default.deleteItem("greeting")
        
        // Then
        XCTAssertTrue(result)
    }
    
    /// Queries for the key which doesn't exist.
    func testNoKeyExists() throws {
        // Given, When
        let result = KeychainService.default.itemExists("nokey")
        
        // Then
        XCTAssertFalse(result)
    }
}
