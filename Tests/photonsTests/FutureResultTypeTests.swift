
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

    func testFutureMappingWithErrorValue() {
        let expValue = expectation(description: "Expect future will be fulfilled with result value")
        
        let future = Future<Result<Int, Error>>()
        future.resolve(with: .failure(NSError(domain: "", code: 22, userInfo: nil)))
        
        future.map { (result) -> String? in
            result.value.map { String.init($0, radix: 16, uppercase: true) }
        }.subscribe { (value) in
            XCTAssertNil(value)
            expValue.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    // MARK: - FlatMap
    
    func testFutureFlatMappingWithResultValue() {
        let expValue = expectation(description: "Expect future will be fulfilled with result value")
        
        let future = Future<Result<Int, Error>>()
        future.resolve(with: .success(10))
        
        future.flatMap { (result) -> Future<String> in
            let newValue = result.value.map { String.init($0, radix: 16, uppercase: true) }
            return Future<String>(newValue!)
        }.subscribe { (value) in
            XCTAssertEqual(value, "A", "value should equal to A")
            expValue.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testFutureFlatMappingWithErrorValue() {
        let expValue = expectation(description: "Expect future will be fulfilled with result value")
        
        let future = Future<Result<Int, Error>>()
        future.resolve(with: .failure(NSError(domain: "", code: 22, userInfo: nil)))
        
        future.flatMap { (result) -> Future<String?> in
            let result = result.value.map { String.init($0, radix: 16, uppercase: true) }
            return Future<String?>(result)
        }.subscribe { (value) in
            XCTAssertNil(value)
            expValue.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    // MARK: - Zip

    func testFutureZippingWithResultValue() {
        let expValue = expectation(description: "Expect future will be fulfilled with result value")
        
        let future1 = Future<Result<Int, Error>>()
        let future2 = Future<Result<String, Error>>()
        
        future1.zip(with: future2).subscribe { (value1, value2) in
            XCTAssertEqual(value1.value , 10, "Value1 should equal to 10")
            XCTAssertEqual(value2.value , "10", "Value2 should equal to '10'")
            expValue.fulfill()
        }
        
        future1.resolve(with: .success(10))
        future2.resolve(with: .success("10"))
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testFutureZippingWithErrorValue() {
        let expValue = expectation(description: "Expect future will be fulfilled with result value")
        
        let future1 = Future<Result<Int, Error>>()
        let future2 = Future<Result<String, Error>>()
        
        future1.zip(with: future2).subscribe { (value1, value2) in
            XCTAssertEqual((value1.error as NSError?)?.code, 22, "")
            XCTAssertEqual((value2.error as NSError?)?.code, 23, "")
            expValue.fulfill()
        }
        
        future1.resolve(with: .failure(NSError(domain: "", code: 22, userInfo: nil)))
        future2.resolve(with: .failure(NSError(domain: "", code: 23, userInfo: nil)))
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
