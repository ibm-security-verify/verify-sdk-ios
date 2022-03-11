//
// Copyright contributors to the IBM Security Verify Core SDK for iOS project
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: Enums

/// An error that occurs during URLSession operations.
public enum URLSessionError: Error, Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    /// - parameter lhs: A value to compare.
    /// - parameter rhs: A value to compare.
    public static func == (lhs: URLSessionError, rhs: URLSessionError) -> Bool {
        guard type(of: lhs) == type(of: rhs) else { return false }
            let error1 = lhs as NSError
            let error2 = rhs as NSError
            return error1.domain == error2.domain && error1.code == error2.code
    }
    
    /// The response data was unexpectedly `nil`.
    case noData
    
    /// Unknown response returned from resource.
    case unknown
    
    /// The resource requires an authenticated credential.
    case unauthenticated
    
    /// An error occured establishing the networking connection.
    case transportFailed(Error)
    
    /// Parsing error occurred during encoding or decodong.
    case parsingFailed
    
    /// The resource returned an error.
    case invalidResource
    
    /// The response returned an error.
    /// - parameter statusCode: The `HTTPURLResponse.statusCode` value.
    /// - parameter description: The response description of the error.
    case invalidResponse(statusCode: Int, description: String)
}

/// Extension to `URLSessionError` for Localizing the error.
extension URLSessionError: LocalizedError {
    /// The localized error description.
    public var errorDescription: String? {
        switch self {
        case .noData:
            return NSLocalizedString(
                "The response data was unexpectedly nil.",
                comment: "No Data"
            )
        case .unknown:
            return NSLocalizedString(
                "Unknown response returned from endpoint.",
                comment: "Unknown"
            )
        case .unauthenticated:
            return NSLocalizedString(
                "The endpoint requires an authenticated credential.",
                comment: "Unauthenticated"
            )
        
        case .transportFailed(let error):
            return NSLocalizedString(
                "An error occured establishing the networking connection.\(error.localizedDescription)",
                comment: "Transport Failed"
            )
        case .parsingFailed:
            return NSLocalizedString(
                "Parsing error occurred during encoding or decodong.",
                comment: "Parsing Failed"
            )
        case .invalidResource:
            return NSLocalizedString(
                "The resource returned an error.",
                comment: "Invalid Resource"
            )
        case .invalidResponse(let statusCode, let description):
            return NSLocalizedString(
                "The response returned an error with status code \(statusCode). \(description)",
                comment: "Invalid Response"
            )
        }
    }
}

/// HTTP response status codes that are acceptable.
var acceptableStatusCodes: Range<Int> { 200..<300 }

// MARK: Helper Functions

/// Creates a URL encoded string for a query string or request body.
/// - parameter params: The parameters to apply.
/// - returns: The encoded string..
public func urlEncode(from params: [String: Any]) -> String {
    var components: [(String, String)] = []

    for key in params.keys.sorted(by: <) {
        let value = params[key]!
        components += queryComponents(fromKey: key, value: value)
    }

    return components.map { "\($0)=\($1)" }.joined(separator: "&")
}

/// Returns a percent-escaped, URL encoded query string components from a key-value pair.
/// - parameter key: The key of the query component.
/// - parameter value: The value of the query component.
/// - returns: The percent-escaped, URL encoded query string components.
private func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
    var components: [(String, String)] = []

    if let dictionary = value as? [String: Any] {
        for (nestedKey, value) in dictionary {
            components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
        }
    }
    else if let array = value as? [Any] {
        for value in array {
            components += queryComponents(fromKey: "\(key)[]", value: value)
        }
    }
    else if let value = value as? NSNumber {
        if value.isBool {
            components.append((key.urlFormEncodedString, value.boolValue ? "1" : "0"))
        }
        else {
            components.append((key.urlFormEncodedString, "\(value)".urlFormEncodedString))
        }
    }
    else if let bool = value as? Bool {
        components.append((key.urlFormEncodedString, bool ? "1" : "0"))
    }
    else {
        components.append((key.urlFormEncodedString, "\(value)".urlFormEncodedString))
    }

    return components
}


// MARK: - Structures

/// A HTTP resource contains a `URLRequest` and the ability to parse the response as a generic type.
public struct HTTPResource<T> {
    /// Represents information about the request.
    var request: URLRequest
    
    /// A function type that attempts to parse the response payload into a generic type.
    var parse: (Data?, URLResponse?) -> Result<T, Error>
    
    /// HTTP method definitions.
    /// See [https://tools.ietf.org/html/rfc7231#section-4.3](https://tools.ietf.org/html/rfc7231#section-4.3)
    public enum method: String {
        /// The GET method requests transfer of a current selected representation for the target resource.
        case get = "GET"

        /// The POST method requests that the target resource process the representation enclosed in the request according to the resource's own specific semantics.
        case post = "POST"

        /// The PUT method requests that the state of the target resource be created or replaced with the state defined by the representation enclosed in the request message payload.
        case put = "PUT"

        /// The PATCH method requests that a set of changes described in the request entity be applied to the resource identified by the Request-URI.
        case patch = "PATCH"

        /// The DELETE method requests that the origin server remove the association between the target resource and its current functionality.
        case delete = "DELETE"
    }
    
    /// The `ContentType` is used to indicate the media type of the resource.
    public enum ContentType: String {
        /// JSON format.
        case json = "application/json"
        /// XML format.
        /// - remark: `application/xml` is recommended as of [RFC 7303](https://datatracker.ietf.org/doc/html/rfc7303#section-4.1)
        case xml = "application/xml"
        
        /// JPEG image format.
        /// - remark: Used for `GET` methods.
        case jpeg = "image/jpeg"
        
        /// The keys and values are encoded in key-value tuples separated by '&', with a '=' between the key and the value.
        /// - remark: Non-alphanumeric characters in both keys and values are percent encoded.
        case urlEncoded = "application/x-www-form-urlencoded"
    }
    
    // MARK: - Initializers
    
    /// Create a new `HttpResource` with request parameters.
    /// - parameter method: The HTTP request method.
    /// - parameter url: The URL of the request.
    /// - parameter accept: The content type for the `Accept` header.
    /// - parameter contentType: The content type for the `Content-Type` header.
    /// - parameter body: The data sent as the message body of a request, such as for an HTTP POST request.
    /// - parameter headers: A dictionary of additional HTTP header fields for a request.
    /// - parameter timeOutInterval: The timeout interval for the request, in seconds. The default is 60.0.
    /// - parameter queryParams: A dictionary of query items to append to the URL.
    /// - parameter parse: A function type  to transforms `T`.
    /// - returns: A `Result` value that represents either a success or a failure, including an associated value in each case.
    public init(_ method: method = .get, url: URL, accept: ContentType? = nil, contentType: ContentType? = nil, body: Data? = nil, headers: [String: String] = [:], timeOutInterval: TimeInterval = 60, queryParams: [String: String] = [:], parse: @escaping (Data?, URLResponse?) -> Result<T, Error>) {
        
        var requestUrl: URL
        
        // Add the dictionary of query parameters to the URL.
        if queryParams.isEmpty {
            requestUrl = url
        }
        else {
            var component = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            component.queryItems = component.queryItems ?? []
            component.queryItems!.append(contentsOf: queryParams.map { URLQueryItem(name: $0.key, value: $0.value) })
            requestUrl = component.url!
        }
        
        request = URLRequest(url: requestUrl)
        
        // Add the accept header.
        if let accept = accept {
            request.setValue(accept.rawValue, forHTTPHeaderField: "Accept")
        }
        
        // Add the content-type.
        if let contentType = contentType {
            request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        }
        
        // Add the additional headers.
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        request.timeoutInterval = timeOutInterval
        request.httpMethod = method.rawValue
        
        // Body property set last because of this issue: https://bugs.swift.org/browse/SR-6687
        request.httpBody = body

        self.parse = parse
    }
    
    /// Creates a new `HttpResource` from a `URLRequest`.
    /// - parameter method: A URL request object that provides request-specific information such as the URL, cache policy, request type, and body data or body stream.
    /// - parameter parse: A function type  to transforms `T`.
    public init(request: URLRequest, parse: @escaping (Data?, URLResponse?) -> Result<T, Error>) {
        self.request = request
        self.parse = parse
    }
    
    // MARK: - Functions
    
    /// Returns an HttpResource containing the results of mapping the given closure over the sequence’s elements.
    /// - parameter transform: A mapping closure. `transform` accepts an element of this sequence as its parameter and returns a transformed value of the same or of a different type.
    /// - returns: A `HttpResource` containing the transformed elements of this sequence.
    public func map<V>(_ transform: @escaping (T) -> V) -> HTTPResource<V> {
        return HTTPResource<V>(request: request) { data, response in
            self.parse(data, response).map(transform)
        }
    }
}

// MARK: Extensions

extension HTTPResource where T == () {
    /// Creates a new `HttpResource` without a parse transformation function.
    /// - parameter method: The HTTP request method.
    /// - parameter url: The URL of the request.
    /// - parameter accept: The content type for the `Accept` header.  Default `application/json`.
    /// - parameter contentType: The content type for the `Content-Type` header.  Default `application/json`.
    /// - parameter body: The data sent as the message body of a request, such as for an HTTP POST request.
    /// - parameter headers: A dictionary of additional HTTP header fields for a request.
    /// - parameter timeOutInterval: The timeout interval for the request, in seconds. The default is 60.0.
    /// - parameter queryParams: A dictionary of query items to append to the URL.
    public init(_ method: method = .get, url: URL, accept: ContentType? = nil, contentType: ContentType? = nil, body: Data? = nil, headers: [String: String] = [:],  timeOutInterval: TimeInterval = 60, queryParams: [String: String] = [:]) {
        self.init(method, url: url, accept: accept, contentType: contentType, body: body, headers: headers, timeOutInterval: timeOutInterval, queryParams: queryParams, parse: { _, _ in .success(()) })
    }
}

extension HTTPResource where T: Decodable {
    /// Creates a new `HttpResource` for JSON operations that have no request body.
    /// - parameter method: The HTTP request method.
    /// - parameter url: The URL of the request.
    /// - parameter accepts: The content type for the `Content-Type` header.  Default `application/json`.
    /// - parameter headers: A dictionary of additional HTTP header fields for a request.
    /// - parameter timeOutInterval: The timeout interval for the request, in seconds. The default is 60.0.
    /// - parameter queryParams: A dictionary of query items to append to the URL.
    /// - parameter decoder: A deccoder used for decoding `T`.  Default is `JSONDecoder`.
    public init(json method: method, url: URL, accept: ContentType = .json, headers: [String: String] = [:], timeOutInterval: TimeInterval = 60, queryParams: [String: String] = [:], decoder: JSONDecoder = JSONDecoder()) {
        self.init(method, url: url, accept: accept, body: nil, headers: headers, timeOutInterval: timeOutInterval, queryParams: queryParams) { data, _ in
            return Result {
                guard let data = data else {
                    throw URLSessionError.noData
                }
                
                return try decoder.decode(T.self, from: data)
            }
        }
    }

    /// Creates a new `HttpResource` for JSON operations with an encodable body.
    /// - parameter method: The HTTP request method.
    /// - parameter url: The URL of the request.
    /// - parameter accepts: The content type for the `Content-Type` header.  Default `application/json`.
    /// - parameter body: The data sent as the message body of a request, such as for an HTTP POST.
    /// - parameter headers: A dictionary of additional HTTP header fields for a request.
    /// - parameter timeOutInterval: The timeout interval for the request, in seconds. The default is 60.0.
    /// - parameter queryParams: A dictionary of query items to append to the URL.
    /// - parameter decoder: A deccoder used for decoding `T`.  Default is `JSONDecoder`.
    /// - parameter encoder: A encoder used for encoding `T`.  Default is `JSONEncoder`.
    public init<V: Encodable>(json method: method, url: URL, accept: ContentType = .json, body: V? = nil, headers: [String: String] = [:], timeOutInterval: TimeInterval = 60, queryParams: [String: String] = [:], decoder: JSONDecoder = JSONDecoder(), encoder: JSONEncoder = JSONEncoder()) {
        let value = body.map { try! encoder.encode($0) }
        
        self.init(method, url: url, accept: accept, contentType: .json, body: value, headers: headers, timeOutInterval: timeOutInterval, queryParams: queryParams) { data, _ in
            return Result {
                guard let data = data else {
                    throw URLSessionError.noData
                }
                
                return try decoder.decode(T.self, from: data)
            }
        }
    }
}

// MARK: - URLSession Extension
extension URLSession {
    /// Creates a task that retrieves the contents of the specified URL, then calls a handler upon completion.
    /// - parameter resource: The `HttpResource` containing the request.
    /// - parameter completionHandler: The completion handler to call when the load request is complete.
    /// - Returns: The new session data task.
    @discardableResult
    public func dataTask<T>(for resource: HTTPResource<T>, completionHandler: @escaping (Result<T, Error>) -> ()) -> URLSessionDataTask {
        
        let task = dataTask(with: resource.request, completionHandler: { data, response, error in
            if let error = error {
                completionHandler(.failure(URLSessionError.transportFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.failure(URLSessionError.unknown))
                return
            }
            
            guard acceptableStatusCodes.contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    completionHandler(.failure(URLSessionError.unauthenticated))
                    return
                }
                
                if let data = data, let description = String(data: data, encoding: .utf8)  {
                    completionHandler(.failure(URLSessionError.invalidResponse(statusCode: httpResponse.statusCode, description: description)))
                }
                
                return
            }

            completionHandler(resource.parse(data, response))
        })
        task.resume()
        return task
    }
}
