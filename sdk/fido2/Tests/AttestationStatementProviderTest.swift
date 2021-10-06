import XCTest
@testable import IBMFIDOKit

class AttestationStatementProviderTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: SelfAttestation
    
    func testCreateSelfAttestation() throws {
        // Given
        let result = SelfAttestation(UUID().uuidString)
        
        // Then
        XCTAssertNotNil(result)
    }
    
    func testInvokdeSelfAttestationStatement() throws {
        // Given
        let result = SelfAttestation(UUID().uuidString)
        
        
        
        // Then
        XCTAssertNotNil(result)
    }

}
