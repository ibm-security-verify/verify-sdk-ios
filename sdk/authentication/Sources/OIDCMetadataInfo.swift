//
// Copyright contributors to the IBM Security Verify Authentication SDK for iOS project
//

import Core

/// The metadata that describes an OpenID Connect  Provider configuration.
public struct OIDCMetadataInfo: Decodable {
    /// The Issuer Identifier of the OpenID Connect Provider. This value is the same as the `iss` claim value in the ID tokens issued by this provider.
    public let issuer: String
    
    /// The URL of the OpenID Connect Provider's OAuth 2.0 Authorization Endpoint.
    public let authorization_endpoint: String
    
    /// The URL of the OpenID Connect Provider's OAuth 2.0 Token Endpoint.
    public let token_endpoint: String
    
    /// The URL of the OpenID Connect Provider's UserInfo Endpoint.
    public let userinfo_endpoint: String
    
    /// The URL of the OpenID Connect Provider's JSON Web Key Set document. This document contains signing keys that clients use to validate the signatures from the provider.
    public let jwks_uri: String
    
    /// The URL of the OpenID Connect Provider's Dynamic Client Registration Endpoint
    public let registration_endpoint: String
   
    /// An array containing a list of OAuth 2.0 response types supported by this provider.
    public  let response_types_supported: [String]
    
    /// An array containing a list of OAuth 2.0 response modes supported by this provider.
    public let response_modes_supported: [String]
    
    /// An array containing a list of OAuth 2.0 grant types supported by this provider.
    ///
    /// If omitted, the default valuea are `authorization_code` and `implicit`.
    /// - remark: Implicit grant type is not supported for mobile.
    public var grant_types_supported: [String] = ["authorization_code", "implicit"]
   
    /// An array containing a list of Subject Identifier types supported by this provider.
    public let subject_types_supported: [String]
    
    /// An array containing a list of the JWS signing algorithms (alg values) supported by this provider for the ID Token to encode the Claims in a JWT.
    public let id_token_signing_alg_values_supported: [String]
   
    /// An array containing a list of the JWE encryption algorithms (alg values) supported by this provider for the ID Token to encode the Claims in a JWT.
    public var id_token_encryption_alg_values_supported: [String] = ["none"]
    
    /// An array containing a list of the JWE encryption algorithms (enc values) supported by this provider for the ID Token to encode the Claims in a JWT.
    public var id_token_encryption_enc_values_supported: [String] = ["none"]
    
    /// An array containing a list of the JWS signing algorithms (alg values) JWA supported by the UserInfo Endpoint to encode the Claims in a JWT.
    public var userinfo_signing_alg_values_supported: [String] = ["none"]
                                                           
    /// An array containing a list of the JWE encryption algorithms (alg values) JWA supported by the UserInfo Endpoint to encode the Claims in a JWT.
    public var userinfo_encryption_alg_values_supported: [String] = ["none"]
    
    /// An array containing a list of the JWE encryption algorithms (enc values) JWA supported by the UserInfo Endpoint to encode the Claims in a JWT.
    public var userinfo_encryption_enc_values_supported: [String] = ["none"]
    
    /// An array containing a list of the JWS signing algorithms (alg values) supported by the OpenID Connect Provider for Request Objects.
    public var request_object_signing_alg_values_supported: [String] = ["none"]
    
    /// An array containing a list of the JWE encryption algorithms (alg values) supported by the OpenID Connect Provider for Request Objects.
    public var request_object_encryption_alg_values_supported: [String] = ["none"]
    
    /// An array containing a list of the JWE encryption algorithms (enc values) supported by the OpenID Connect Provider for Request Objects.
    public var request_object_encryption_enc_values_supported: [String] = ["none"]
    
    /// An array containing a list of Client Authentication methods supported by this Token Endpoint. The options are `client_secret_post`, `client_secret_basic`, `client_secret_jwt`, and `private_key_jwt`.
    ///
    /// If omitted, the default value is `client_secret_basic`.
    public var token_endpoint_auth_methods_supported: [String] = ["client_secret_basic"]
    
    /// An array containing a list of the JWS signing algorithms (alg values) supported by the Token Endpoint for the signature on the JWT used to authenticate the Client at the Token Endpoint for the `private_key_jwt` and `client_secret_jwt` authentication methods.
    public var token_endpoint_auth_signing_alg_values_supported: [String]?
    
    /// An array containing a list of the display parameter values that the OpenID Provider supports.
    public var display_values_supported: [String]?
    
    /// An array containing a list of the Claim Types that the OpenID Provider supports.
    ///
    /// If omitted, the default value is `normal`.
    public var claim_types_supported: [String] = ["normal"]
    
    /// An array containing a list of the Claim Names of the Claims that the OpenID Provider **may** be able to supply values for.
    public var claims_supported: [String] = []
    
    /// A URL of a page containing human-readable information that developers might want or need to know when using the OpenID Provider.
    public let service_documentation: String?
    
    /// An array of languages and scripts supported for values in Claims being returned.
    public let claims_locales_supported: [String]?
    
    /// An array of languages and scripts supported for the user interface.
    public let ui_locales_supported: [String]?
    
    /// A boolean value specifying whether the OpenID Provider supports use of the claims parameter, with `true` indicating support.
    ///
    /// If omitted, the default value is `false`.
    @Default.False public var claims_parameter_supported: Bool
    
    /// A boolean value specifying whether the OpenID Provider supports use of the request parameter, with true indicating support.
    ///
    /// If omitted, the default value is `false`.
    @Default.False public var request_parameter_supported: Bool
   
    /// A boolean value specifying whether the OpenID Provider supports use of the `request_uri` parameter, with `true` indicating support.
    ///
    /// If omitted, the default value is `true`.
    @Default.True public var request_uri_parameter_supported: Bool
    
    /// A boolean value specifying whether the OpenID Provider requires any `request_uri` values used to be pre-registered using the `request_uris` registration parameter. Pre-registration is **required** when the value is `true`.
    ///
    /// If omitted, the default value is `false`.
    @Default.False public var require_request_uri_registration: Bool
   
    /// A  URL that the OpenID Provider provides to the person registering the Client to read about the OP's requirements on how the Relying Party can use the data provided by the OpenID Provider.
    public let op_policy_uri: String?
    
    /// A URL that the OpenID Provider provides to the person registering the Client to read about OpenID Provider's terms of service.
    public let op_tos_uri: String?
}
