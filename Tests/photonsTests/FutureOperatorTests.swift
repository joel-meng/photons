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
    
    // MARK: - Flat Map operator
    
    func testFlatMapOperator() {
        let exp = expectation(description: "Expect same value passed on to next future")
        let future1 = Future(1)
        (future1 ||| { (value: Int) -> Future<Int> in
            return Future<Int>(value * 2)
        }).onComplete { value in
            XCTAssertEqual(value, 2)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testFlatMapOperatorWithDelay() {
        let exp = expectation(description: "Expect same value passed on to next future")
        let future1 = Future(1)
        (future1 ||| { (value: Int) -> Future<Int> in
            let future = Future<Int>()
            (delayContext(.milliseconds(100))) {
                future.resolve(with: value * 2)
            }
            return future
        }).onComplete { value in
            XCTAssertEqual(value, 2)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testFlatMapOperatorToDifferentType() {
        let toHexStringFuture: (Int) -> Future<String> = { inValue in
            Future<String> { resolve in
                resolve(String(inValue, radix: 16, uppercase: true))
            }
        }
        (Future(15) ||| toHexStringFuture).onComplete { value in
            XCTAssertEqual(value, "F")
        }
    }
    
    // MARK: - Zip

    }
