//
//  FutureOperatorTests.swift
//  photonsTests
//
//  Created by Jun Meng on 20/5/20.
//

import XCTest
@testable import photons

class FutureMapOperatorTests: XCTestCase {
    
    // MARK: - Original future resolved immediately
    
    func testMapOperator_OriginalFutureResolvedImmediately() {
        let exp = expectation(description: "subscription called with right hex value")
        let doubleTheNumber = { $0 * 2 }
        (Future(1) >>> doubleTheNumber).onComplete { value in
            XCTAssertEqual(value, 2)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testMapOperatorToDifferentType_OriginalFutureResolvedImmediately() {
        let exp = expectation(description: "subscription called with right hex value")
        let toHexString: (Int) -> String = { String($0, radix: 16, uppercase: true) }
        (Future(15) >>> toHexString).onComplete { value in
            XCTAssertEqual(value, "F")
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testMapOperatorWithDelayResolving_OriginalFutureResolvedImmediately() {
        let exp = expectation(description: "subscription called with right hex value")
        
        let future = Future<Int>(15)
        let toHexString: (Int) -> String = { String($0, radix: 16, uppercase: true) }
        
        (future >>> toHexString).onComplete { value in
            XCTAssertEqual(value, "F")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    // MARK: - Original future resolved lately
    
    func testMapOperator_OriginalFutureResolvedLately() {
        let exp = expectation(description: "subscription called with right hex value")
        let future = Future<Int>()
        let doubleTheNumber = { $0 * 2 }
        (future >>> doubleTheNumber).onComplete { value in
            XCTAssertEqual(value, 2)
            exp.fulfill()
        }
        future.resolve(with: 1)
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testMapOperatorToDifferentType_OriginalFutureResolvedLately() {
        let exp = expectation(description: "subscription called with right hex value")
        let future = Future<Int>()
        let toHexString: (Int) -> String = { String($0, radix: 16, uppercase: true) }
        (future >>> toHexString).onComplete { value in
            XCTAssertEqual(value, "F")
            exp.fulfill()
        }
        future.resolve(with: 15)
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testMapOperatorWithDelayResolving_OriginalFutureResolvedLately() {
        let exp = expectation(description: "subscription called with right hex value")
        let future = Future<Int>()
        let toHexString: (Int) -> String = { String($0, radix: 16, uppercase: true) }
        (future >>> toHexString).onComplete { value in
            XCTAssertEqual(value, "F")
            exp.fulfill()
        }
        (delayContext(.milliseconds(100))) {
            future.resolve(with: 15)
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
