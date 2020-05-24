
//
//  FutureResultTypeTests.swift
//  photonsTests
//
//  Created by Jun Meng on 24/5/20.
//

import XCTest
@testable import photons

class FutureResultsTests: XCTestCase {
    
    func testFutureWithResultValue() {
        let expValue = expectation(description: "Expect future will be fulfilled with result value")
        let expError = expectation(description: "Expect future will NOT be fulfilled with error")
        expError.isInverted = true
        
        let future = Future<Result<Int, Error>>()
        future.resolve(with: .success(10))
        future.subscribeSuccess { value in
            XCTAssertEqual(value, 10, "value should equal to 10")
            expValue.fulfill()
        }
        future.subscribeError { (error) in
            expError.fulfill()
        }
        
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testFutureWithResultError() {
        let expValue = expectation(description: "Expect future will be fulfilled with result value")
        let expError = expectation(description: "Expect future will NOT be fulfilled with error")
        expValue.isInverted = true
        
        let future = Future<Result<Int, Error>>()
        future.resolve(with: .failure(NSError(domain: "", code: 22, userInfo: nil)))
        future.subscribeSuccess { value in
            expValue.fulfill()
        }
        future.subscribeError { (error) in
            XCTAssertEqual((error as NSError).code, 22, "Should equal to the same error code")
            expError.fulfill()
        }
        
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testFutureWithResultValue_OnSubscribeSuccessErrorFunction() {
        let expValue = expectation(description: "Expect future will be fulfilled with result value")
        let expError = expectation(description: "Expect future will NOT be fulfilled with error")
        expError.isInverted = true
        
        let future = Future<Result<Int, Error>>()
        future.resolve(with: .success(10))
        
        future.subscribe(success: { (value) in
            XCTAssertEqual(value, 10, "value should equal to 10")
            expValue.fulfill()
        }, error: { error in
            expError.fulfill()
        })
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testFutureWithErrorValue_OnSubscribeSuccessErrorFunction() {
        let expValue = expectation(description: "Expect future will be fulfilled with result value")
        let expError = expectation(description: "Expect future will NOT be fulfilled with error")
        expValue.isInverted = true
        
        let future = Future<Result<Int, Error>>()
        future.resolve(with: .failure(NSError(domain: "", code: 22, userInfo: nil)))
        
        future.subscribe(success: { (value) in
            expValue.fulfill()
        }, error: { error in
            XCTAssertEqual((error as NSError).code, 22, "Should equal to the same error code")
            expError.fulfill()
        })
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    // MARK: - Map
    
    func testFutureMappingWithResultValue() {
        let expValue = expectation(description: "Expect future will be fulfilled with result value")
        
        let future = Future<Result<Int, Error>>()
        future.resolve(with: .success(10))
        
        future.map { (result) -> String? in
            result.value.map { String.init($0, radix: 16, uppercase: true) }
        }.subscribe { (value) in
            XCTAssertEqual(value, "A", "value should equal to A")
            expValue.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    // MARK: - FlatMap
    
    // MARK: - Zip
}


