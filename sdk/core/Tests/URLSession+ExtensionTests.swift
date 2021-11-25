//
// Copyright contributors to the IBM Security Verify Core SDK for iOS project
//

import XCTest
@testable import Core

class URLSessionExtensionTests: XCTestCase {
    /// - remark: The URL for posts contains 100 items.
    let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
    
    // Static Post objects
    let newPost = Post(userId: 201, id: 201, title: "Test Core", body: "Test post body.")
    let updatePost = Post(userId: 1, id: 1, title: "Test Core", body: "Test post body.")

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    struct Post: Codable {
        var userId: Int
        var id: Int
        var title: String
        var body: String
    }
    
    // MARK:- Initializer tests
    
    /// Get an array todo items.
    func testInitJsonAll() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://jsonplaceholder.typicode.com/posts")
        let resource = HttpResource<[Post]>(json: .get, url: url)
        
        // Where
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(let value):
                XCTAssertTrue(value.count == 100)
            case .failure(let error):
                XCTAssertFalse(false, error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    /// Get the first todo items.
    func testInitJsonFirst() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://jsonplaceholder.typicode.com/posts/1")
        let url = self.url.appendingPathComponent("1")
        let resource = HttpResource<Post>(json: .get, url: url)
        
        // Where, Then
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(let value):
                XCTAssertNotNil(value)
            case .failure(let error):
                XCTAssertFalse(false, error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    /// Get an array todo items to map titles.
    func testInitJsonFilter() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://jsonplaceholder.typicode.com/posts?userId=1")
        let resource = HttpResource<[Post]>(json: .get, url: url, queryParams: ["userId": "1"])
        
        // Where
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(let value):
                XCTAssertTrue(value.count == 10)
            case .failure(let error):
                XCTAssertFalse(false, error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    
    /// Get an array posts items to map to the first item.
    func testInitJsonMap() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://jsonplaceholder.typicode.com/posts")
        let posts = HttpResource<[Post]>(json: .get, url: url)
        let firstPost = posts.map{ $0.first }
        
        // Where
        URLSession.shared.dataTask(for: firstPost) { result in
            switch result {
            case .success(let value):
                XCTAssertEqual(value?.id, 1)
            case .failure(let error):
                XCTAssertFalse(false, error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    /// Get an array todo items with request and parse.
    func testInitAllRequestAndParse() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://jsonplaceholder.typicode.com/posts")
        let request = URLRequest(url: url)
        let resource = HttpResource<[Post]>(request: request, parse: { data, response in
            do {
                let value = try JSONDecoder().decode([Post].self, from: data!)
                return Result.success(value)
            }
            catch(let error) {
                return Result.failure(error)
            }
        })
        
        // Where
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(let value):
                let titles = value.map { $0.title }
                XCTAssertEqual(titles.count, 100)
            case .failure(let error):
                XCTAssertFalse(false, error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    /// Tests overloaded init with a PUT.
    func testInitJsonMinimumParams() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://jsonplaceholder.typicode.com/posts/1")
        let url = self.url.appendingPathComponent("1")
        let resource = HttpResource<Post>(json: .put, url: url, body: updatePost)
        
        // Where
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(let value):
                XCTAssertEqual(value.body, self.newPost.body)
            case .failure(let error):
                XCTAssertFalse(true, error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    /// Tests overloaded init with a PATCH.
    func testInitJsonAllParams() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://jsonplaceholder.typicode.com/posts/1")
        let url = self.url.appendingPathComponent("1")
        
        struct PostTitle: Encodable {
            var title: String
        }
        
        let updateTitle = PostTitle(title: "Update Test Core")
        
        let resource = HttpResource<Post>(json: .patch, url: url, accept: .json, body: updateTitle, timeOutInterval: 15, decoder: JSONDecoder(), encoder: JSONEncoder())
        
        // Where
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(let value):
                XCTAssertEqual(value.title, updateTitle.title)
            case .failure(let error):
                XCTAssertFalse(true, error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    /// Tests overloaded init JSON with an encoder.
    func testInitJsonEncoder() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://jsonplaceholder.typicode.com/posts")
        let url = self.url.appendingPathComponent("1")
        
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .deferredToData
        
        let resource = HttpResource<Post>(json: .put, url: url, accept: .json, body: updatePost, headers: ["header1": "header1", "header2": "header2"], timeOutInterval: 15, queryParams: ["userId":"1"], encoder: encoder)
        
        // Where
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(let value):
                XCTAssertEqual(value.title, "Test Core")
            case .failure(let error):
                XCTAssertFalse(true, error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    
    /// Tests overloaded init with a DELETE.
    func testInitMinimumParams() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://jsonplaceholder.typicode.com/posts/1")
        let url = self.url.appendingPathComponent("1")
        let resource = HttpResource(.delete, url: url)
        
        // Where
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(_):
                XCTAssertTrue(true)
            case .failure(let error):
                XCTAssertFalse(true, error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    
    /// Tests overloaded init with a POST.
    func testInitAllParamsFilter() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://jsonplaceholder.typicode.com/posts")
        let body = try! JSONEncoder().encode(newPost)
        
        let resource = HttpResource<()>(.post, url: url, accept: .json, contentType: .json, body: body, headers: ["header1": "header1", "header2": "header2"], timeOutInterval: 15, queryParams: [:])
        
        // Where
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(_):
                XCTAssertTrue(true)
            case .failure(let error):
                XCTAssertFalse(true, error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    /// Tests overloaded init with a PATCH.
    func testInitAllParams() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://jsonplaceholder.typicode.com/posts")
        let url = self.url.appendingPathComponent("1")
        let body = """
            {
                "title": "Update post"
            }
        """
      
        let resource = HttpResource<Post>(.patch, url: url, accept: .json, contentType: .json, body: body.data(using: .utf8), headers: ["header1": "header1", "header2": "header2"], timeOutInterval: 15, queryParams: [:], parse: { data, response in
            do {
                let value = try JSONDecoder().decode(Post.self, from: data!)
                return Result.success(value)
            }
            catch(let error) {
                return Result.failure(error)
            }
        })
        
        // Where
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(let value):
                XCTAssertEqual(value.title, "Update post")
            case .failure(let error):
                XCTAssertFalse(true, error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    /// Tests overloaded init returning an UIImage
    func testInitImageResource() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://picsum.photos/id/0/5616/3744")
        let url = URL(string: "https://picsum.photos/id/0/5616/3744")!
        let resource = HttpResource<UIImage>(.get, url: url, accept: .jpeg) { data, response in
            return Result {
                guard let data = data, let image = UIImage(data: data) else {
                    throw URLSessionError.noData
                }
                
                return image
            }
        }
        
        // Where
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(_):
                XCTAssertTrue(true)
            case .failure(let error):
                XCTAssertFalse(true, error.localizedDescription)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    
    // MARK: - Error handling
    
    static func throwError(_ error: URLSessionError) throws {
        throw error
    }
    
    /// Tests no data error
    func testURLSessionErrorNoData() throws {
        // Given
        var thrownError: Error?

        // When
        XCTAssertThrowsError(try URLSessionExtensionTests.throwError(.noData)) {
            thrownError = $0
        }

        // Then
        XCTAssertTrue(thrownError is URLSessionError, "Unexpected error type: \(type(of: thrownError))")

        // Then
        XCTAssertEqual(thrownError as? URLSessionError, .noData)
        
        // Then
        XCTAssertEqual(thrownError?.localizedDescription, URLSessionError.noData.localizedDescription)
    }
    
    /// Tests unknown error
    func testURLSessionErrorUnknown() throws {
        // Given
        var thrownError: Error?

        // When
        XCTAssertThrowsError(try URLSessionExtensionTests.throwError(.unknown)) {
            thrownError = $0
        }

        // Then
        XCTAssertTrue(thrownError is URLSessionError, "Unexpected error type: \(type(of: thrownError))")

        // Then
        XCTAssertEqual(thrownError as? URLSessionError, .unknown)
        
        // Then
        XCTAssertEqual(thrownError?.localizedDescription, URLSessionError.unknown.localizedDescription)
    }
    
    /// Tests unauthenticated error
    func testURLSessionErrorUnauthenticated() throws {
        // Given
        var thrownError: Error?

        // When
        XCTAssertThrowsError(try URLSessionExtensionTests.throwError(.unauthenticated)) {
            thrownError = $0
        }

        // Then
        XCTAssertTrue(thrownError is URLSessionError, "Unexpected error type: \(type(of: thrownError))")

        // Then
        XCTAssertEqual(thrownError as? URLSessionError, .unauthenticated)
        
        // Then
        XCTAssertEqual(thrownError?.localizedDescription, URLSessionError.unauthenticated.localizedDescription)
    }
    
    /// Tests transport failed error
    func testURLSessionErrorTransportFailed() throws {
        // Given
        var thrownError: Error?

        // When
        XCTAssertThrowsError(try URLSessionExtensionTests.throwError(.transportFailed(NSError(domain: "URLSessionError", code: -1)))) {
            thrownError = $0
        }

        // Then
        XCTAssertTrue(thrownError is URLSessionError, "Unexpected error type: \(type(of: thrownError))")

        // Then
        XCTAssertEqual(thrownError as? URLSessionError, .transportFailed(NSError(domain: "URLSessionError", code: -1)))
        
        // Then
        XCTAssertEqual(thrownError?.localizedDescription, URLSessionError.transportFailed(NSError(domain: "URLSessionError", code: -1)).localizedDescription)
    }
    
    /// Tests parsingFailed error
    func testURLSessionErrorParsingFailed() throws {
        // Given
        var thrownError: Error?

        // When
        XCTAssertThrowsError(try URLSessionExtensionTests.throwError(.parsingFailed)) {
            thrownError = $0
        }

        // Then
        XCTAssertTrue(thrownError is URLSessionError, "Unexpected error type: \(type(of: thrownError))")

        // Then
        XCTAssertEqual(thrownError as? URLSessionError, .parsingFailed)
        
        // Then
        XCTAssertEqual(thrownError?.localizedDescription, URLSessionError.parsingFailed.localizedDescription)
    }
    
    /// Tests invalidResource error
    func testURLSessionErrorInvalidResource() throws {
        // Given
        var thrownError: Error?

        // When
        XCTAssertThrowsError(try URLSessionExtensionTests.throwError(.invalidResource)) {
            thrownError = $0
        }

        // Then
        XCTAssertTrue(thrownError is URLSessionError, "Unexpected error type: \(type(of: thrownError))")

        // Then
        XCTAssertEqual(thrownError as? URLSessionError, .invalidResource)
        
        // Then
        XCTAssertEqual(thrownError?.localizedDescription, URLSessionError.invalidResource.localizedDescription)
    }
    
    /// Tests invalidResponse error
    func testURLSessionErrorInvalidResponse() throws {
        // Given
        var thrownError: Error?

        // When
        XCTAssertThrowsError(try URLSessionExtensionTests.throwError(.invalidResponse(404))) {
            thrownError = $0
        }

        // Then
        XCTAssertTrue(thrownError is URLSessionError, "Unexpected error type: \(type(of: thrownError))")

        // Then
        XCTAssertEqual(thrownError as? URLSessionError, .invalidResponse(404))
        
        // Then
        XCTAssertEqual(thrownError?.localizedDescription, URLSessionError.invalidResponse(404).localizedDescription)
    }
    
    /// Tests unauthenticated error responses
    func testDataTaskUnauthenticated() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://api.github.com")
        let url = URL(string: "https://api.github.com")!
        let resource = HttpResource<()>(.get, url: url, headers: ["Authorization": "Bearer abc123"])
        
        // Where
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(_):
                XCTFail("A response in the 200 range was not expected.")
            case .failure(let error):
                XCTAssertEqual(error as? URLSessionError, URLSessionError.unauthenticated)
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    /// Tests invalid response 404 error.
    func testDataTaskInvalidResponse() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://api.github.com")
        let url = URL(string: "https://api.github.com")!
        let resource = HttpResource<()>(.post, url: url)
        
        // Where
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(_):
                XCTFail("A response in the 200 range was not expected.")
            case .failure(let error):
                XCTAssertEqual(error as? URLSessionError, URLSessionError.invalidResponse(404))
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
    
    /// Tests transport failed due to the host being invalid.
    func testDataTaskTransportFailed() throws {
        // Given
        let expectation = XCTestExpectation(description: "Testing https://nohost.com")
        let url = URL(string: "https://nohost.com")!
        let resource = HttpResource<()>(.get, url: url)
        
        // Where
        URLSession.shared.dataTask(for: resource) { result in
            switch result {
            case .success(_):
                XCTFail("A response in the 200 range was not expected.")
            case .failure(let error):
                XCTAssertEqual(error as? URLSessionError, .transportFailed(NSError(domain: "kCFErrorDomainCFNetwork", code: -1004)))
            }
            
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 30.0)
    }
}
