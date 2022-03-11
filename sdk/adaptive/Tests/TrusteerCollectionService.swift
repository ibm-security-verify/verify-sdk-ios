//
// Copyright contributors to the IBM Security Verify Adaptive SDK for iOS project
//

import Foundation
import tazSDK
@testable import Adaptive

class TrusteerCollectionService: AdaptiveCollectionService {
    /// The identifier of the vendor.
    public let vendorId: String
    
    /// The client identifier.
    public let clientId: String

    /// The client key.
    public let clientKey: String
    
    // MARK: Initializer
    
    /// Initializes a new instance of `TrusteerCollectionService` for activating the collection process.
    /// - parameter vendorId: The identifier of the vendor.
    /// - parameter clientId: The client identifier.
    /// - parameter clientKey: The client key.
    ///
    /// ```
    /// let trusterCollector = TrusteerAdaptiveCollection(using "BCD234", clientId: "CDE345", clientKey: "DEF456")
    /// ```
    public init(using vendorId: String, clientId: String, clientKey: String) {
        self.vendorId = vendorId
        self.clientId = clientId
        self.clientKey = clientKey
    }
    
    // MARK: AdaptiveCollection SDK Functions
    
    /// Starts the collection operation.
    /// - parameter sessionId: The session identifier for the hosting application.
    /// - remark: This operation associates the `sessionId` with adaptive authenticaton.
    /// - throws: `TrusteerOperationError` containing the error.
    public func start(with sessionId: String) throws -> Void {
        var clientInfo = TAS_CLIENT_INFO(size: Int32(MemoryLayout<TAS_CLIENT_INFO>.size),
                                         vendorId: NSString(string: vendorId).utf8String,
                                         clientId: NSString(string: clientId).utf8String,
                                         comment: nil,
                                         clientKey: NSString(string: clientKey).utf8String)
            
        let options = TAS_INIT_NO_OPT
        let result = TasStart(&clientInfo, options, nil, 0, sessionId)
        print("Trusteer start status. \(result == TAS_RESULT_SUCCESS ? "Success" : TrusteerOperationError.init(value: result).localizedDescription)")
        
        if result != TAS_RESULT_SUCCESS {
            throw TrusteerOperationError(value: result)
        }
    }
    
    /// Stops the collection operation.
    /// - throws: `TrusteerOperationError` containing the error.
    public func stop() throws -> Void {
        let result = TasStop()
        print("Trusteer stop status. \(result == TAS_RESULT_SUCCESS ? "Success" : TrusteerOperationError.init(value: result).localizedDescription)")
        
        if result != TAS_RESULT_SUCCESS {
            throw TrusteerOperationError(value: result)
        }
    }
    
    /// Resets the collection operation with a new session identifier
    /// - parameter sessionId: The session identifier for the hosting application.
    /// - throws: `TrusteerOperationError` containing the error.
    public func reset(new sessionId: String) throws -> Void {
        // Invoke the Trusteer SDK to reset the sessionId.
        let result = TasResetSession(sessionId)
        
        print("Trusteer reset status. \(result == TAS_RESULT_SUCCESS ? "Success" : TrusteerOperationError.init(value: result).localizedDescription)")
        
        if result != TAS_RESULT_SUCCESS {
            throw TrusteerOperationError(value: result)
        }
    }
}


// MARK: Trusteer Errors

/// Defines the return value when an adaptive start or stop operation occurs.
public enum TrusteerOperationError : Error {
    /// A general error occured during the collection process.
    case generalError
    /// An internal error occured.  Contact support.
    case internalError
    /// The argument to initiate the collection process were incorrect.
    case incorrectArguments
    /// The reference DRA item was not found.
    case notFound
    /// No polling has been configured.
    case noPolling
    /// Time out occured.
    case timeOut
    /// The TAS collection process not initialized
    case notInitialized
    /// Licence not authorized to perform operation.
    case licenceNotAuthorized
    /// The TAS collection process already initialized.
    case alreadyInitialized
    /// Architecture not supported.
    case architectureNotSupported
    /// Incorrect TAS setup.
    case incorrectSetup
    /// An internal exception occured. Contact support.
    case internalException
    /// Insufficient permissions for collection process.
    case insufficientPermissions
    /// Missing permission in tas folder or tas folder does not exist.
    case missingPermissionInFolder
    /// TAS collection disabled due to configuration options.
    case disabledByConfiguration
    /// A network error occured.
    case networkError
    /// The internal connection timed out.  Contact support.
    case internalConnectionTimeout
    /// Certicate error.  Contact support.
    case certificateError
    
    /// Initializes the `AdaptiveOperationError`  enum type from a `TAS_RESULT`.
    /// - parameter value: The name of a factor.
    internal init(value: TAS_RESULT) {
        switch value {
        case TAS_RESULT_GENERAL_ERROR:
            self = .generalError
        case TAS_RESULT_INTERNAL_ERROR:
            self = .internalError
        case TAS_RESULT_WRONG_ARGUMENTS:
            self = .incorrectArguments
        case TAS_RESULT_DRA_ITEM_NOT_FOUND:
            self = .notFound
        case TAS_RESULT_NO_POLLING:
            self = .noPolling
        case TAS_RESULT_TIMEOUT:
            self = .timeOut
        case TAS_RESULT_NOT_INITIALIZED:
            self = .notInitialized
        case TAS_RESULT_UNAUTHORIZED:
            self = .licenceNotAuthorized
        case TAS_RESULT_ALREADY_INITIALIZED:
            self = .alreadyInitialized
        case TAS_RESULT_ARCH_NOT_SUPPORTED:
            self = .architectureNotSupported
        case TAS_RESULT_INCORRECT_SETUP:
            self = .incorrectSetup
        case TAS_RESULT_INTERNAL_EXCEPTION:
            self = .internalException
        case TAS_RESULT_INSUFFICIENT_PERMISSIONS:
            self = .insufficientPermissions
        case TAS_RESULT_MISSING_PERMISSIONS_IN_FOLDER:
            self = .missingPermissionInFolder
        case TAS_RESULT_DISABLED_BY_CONFIGURATION:
            self = .disabledByConfiguration
        case TAS_RESULT_NETWORK_ERROR:
            self = .networkError
        case TAS_RESULT_CONNECTION_INTERNAL_TIMEOUT:
            self = .internalConnectionTimeout
        case TAS_RESULT_PINPOINT_CERTIFICATE_PROBLEM:
            self = .certificateError
        default:
            self = .generalError
        }
    }
}

extension TrusteerOperationError: LocalizedError {
    /// Gets the error description.
    public var errorDescription: String? {
        switch self {
        case .generalError:
            return NSLocalizedString("A general error occured during the collection process.", comment: "")
        case .internalError, .internalException:
            return NSLocalizedString("An internal error occured.  Contact support.", comment: "")
        case .incorrectArguments:
            return NSLocalizedString("The argument to initiate the collection process were incorrect.", comment: "")
        case .notFound:
            return NSLocalizedString("The reference DRA item was not found.", comment: "")
        case .noPolling:
            return NSLocalizedString("No polling has been configured.", comment: "")
        case .timeOut, .internalConnectionTimeout:
            return NSLocalizedString("Time out occured.", comment: "")
        case .notInitialized:
            return NSLocalizedString("The TAS collection process not initialized.", comment: "")
        case .licenceNotAuthorized:
            return NSLocalizedString("Licence not authorized to perform operation.", comment: "")
        case .alreadyInitialized:
            return NSLocalizedString("The TAS collection process already initialized.", comment: "")
        case .architectureNotSupported:
            return NSLocalizedString("Architecture not supported.", comment: "")
        case .incorrectSetup:
            return NSLocalizedString("Incorrect TAS setup.", comment: "")
        case .insufficientPermissions:
            return NSLocalizedString("Insufficient permissions for collection process.", comment: "")
        case .missingPermissionInFolder:
            return NSLocalizedString("Missing permission in tas folder or tas folder does not exist.", comment: "")
        case .disabledByConfiguration:
            return NSLocalizedString("TAS collection disabled due to configuration options.", comment: "")
        case .networkError:
            return NSLocalizedString("A network error occured.", comment: "")
        case .certificateError:
            return NSLocalizedString("Certicate error.  Contact support.", comment: "")
        }
    }
}
