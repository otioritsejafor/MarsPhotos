//
//  MarsPhotosTests.swift
//  MarsPhotosTests
//
//  Created by Oti Oritsejafor on 6/23/20.
//  Copyright © 2020 Magloboid. All rights reserved.
//

import XCTest
@testable import MarsPhotos

final class MarsPhotosAsynchronousTests: XCTestCase {
    var expectation: XCTestExpectation!
    let timeout: TimeInterval = 2
    
    override func setUp() {
        expectation = expectation(description: "Server responds in reasonable time")
    }
    
    func test_decodeRoverData() {
        let url = URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers/opportunity/photos?sol=1000&page=1&api_key=DEMO_KEY")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
                defer { self.expectation.fulfill() }
                XCTAssertNil(error)
                
            do {
                let response = try XCTUnwrap(response as? HTTPURLResponse)
                XCTAssertEqual(response.statusCode, 200)
                
                let data = try XCTUnwrap(data)
                XCTAssertNoThrow(
                    try JSONDecoder().decode(RoverData.self, from: data)
                )
                
            } catch { }
        }
        .resume()
        
        waitForExpectations(timeout: timeout)
        
    }
    
    func test_404() {
        let url = URL(string: "https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/somethingwronghere?sol=500&api_key=kHZkrwGYdjLTFBqRQLUFF3pGKhKrFBQJoY3FeGbH")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
                defer { self.expectation.fulfill() }
                XCTAssertNil(error)
                
            do {
                let response = try XCTUnwrap(response as? HTTPURLResponse)
                XCTAssertEqual(response.statusCode, 404)
                
                let data = try XCTUnwrap(data)
                XCTAssertThrowsError(
                    try JSONDecoder().decode(RoverData.self, from: data)
                ) { error in
                    guard case DecodingError.dataCorrupted = error else {
                        XCTFail("\(error)")
                        return
                    }
                }
                
            } catch { }
        }
        .resume()
        
        waitForExpectations(timeout: timeout)
    }
    
    func test_client() throws {
        struct FakeDataTaskMaker: DataTaskMaker {
            static let dummyURL = URL(string: "dummy")!
            
            init() throws {
                let testBundle = Bundle(for: MarsPhotosAsynchronousTests.self)
                let url = try XCTUnwrap(
                    testBundle.url(forResource: "photos", withExtension: "json")
                )
                data = try Data(contentsOf: url)
            }
            
            let data: Data
            
            func dataTask(with _: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
                completionHandler(data, HTTPURLResponse(url: Self.dummyURL,
                           statusCode: 200,
                           httpVersion: nil,
                           headerFields: nil
                         ),
                         nil
                       )

                       final class FakeDataTask: URLSessionDataTask {
                         override init() { }
                       }
                       return FakeDataTask()
            }
        }
        
        _ = NasaClient(session: try FakeDataTaskMaker(), baseURL: FakeDataTaskMaker.dummyURL).getOpportunityPhotos(page: 0) { (roverData, error) in
            defer { self.expectation.fulfill() }
            
            XCTAssertTrue((roverData?.photos.count)! > 0)
            XCTAssertNil(error)
        }
        
        waitForExpectations(timeout: 0.1)
    }
}
