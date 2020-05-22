//
//  FutureOperatorTests.swift
//  photonsTests
//
//  Created by Jun Meng on 20/5/20.
//

import XCTest
@testable import photons

class FutureOperatorTests: XCTestCase {
    
    // MARK: - Map operator
    
    func testMapOperator() {
        let doubleTheNumber = { $0 * 2 }
        (Future(1) >>> doubleTheNumber)
            .onComplete { value in XCTAssertEqual(value, 2) }
    }
    
    func testMapOperatorToDifferentType() {
        let toHexString: (Int) -> String = { String($0, radix: 16, uppercase: true) }
        (Future(15) >>> toHexString).onComplete { value in
            XCTAssertEqual(value, "F")
        }
    }
    
    func testMapOperatorWithDelayResolving() {
        let exp = expectation(description: "subscription called with right hex value")
        
        let future = Future<Int> { resolver in
            (delayContext(.milliseconds(200))) {
                resolver(15)
            }
        }
        let toHexString: (Int) -> String = { String($0, radix: 16, uppercase: true) }
        
        (future >>> toHexString).onComplete { value in
            XCTAssertEqual(value, "F")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
