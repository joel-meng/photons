//
//  FutureFlatMapOperatorTests.swift
//  photonsTests
//
//  Created by Jun Meng on 22/5/20.
//

import XCTest
@testable import photons

class FutureFlatMapOperatorTests: XCTestCase {
    
    // MARK: - Original Future being resolved immediately
 
    func testFlatMapOperator_OriginalFutureResolvedImmediately() {
        let exp = expectation(description: "Expect same value passed on to next future")
        let future1 = Future(1)
        
        (future1 ||| { (value: Int) -> Future<Int> in
            return Future<Int>(value * 2)
        }).subscribe { value in
            XCTAssertEqual(value, 2)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testFlatMapOperatorWithDelay_OriginalFutureResolvedImmediately() {
        let exp = expectation(description: "Expect same value passed on to next future")
        let future1 = Future(1)
        (future1 ||| { (value: Int) -> Future<Int> in
            let future = Future<Int>()
            (delayContext(.milliseconds(100))) {
                future.resolve(with: value * 2)
            }
            return future
        }).subscribe { value in
            XCTAssertEqual(value, 2)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testFlatMapOperatorToDifferentType_OriginalFutureResolvedImmediately() {
        let toHexStringFuture: (Int) -> Future<String> = { inValue in
            Future<String> { resolve in
                resolve(String(inValue, radix: 16, uppercase: true))
            }
        }
        (Future(15) ||| toHexStringFuture).subscribe { value in
            XCTAssertEqual(value, "F")
        }
    }
    
    // MARK: - Original Future being resolved immediately
    
    func testFlatMapOperator_OriginalFutureResolvedLately() {
        let exp = expectation(description: "Expect same value passed on to next future")
        let future = Future<Int>()
        
        (future ||| { (value: Int) -> Future<Int> in
            return Future<Int>(value * 2)
        }).subscribe { value in
            XCTAssertEqual(value, 2)
            exp.fulfill()
        }
        
        future.resolve(with: 1)
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testFlatMapOperator_OriginalFutureResolvedLatelyWithDelay() {
        let exp = expectation(description: "Expect same value passed on to next future")
        let future = Future<Int>()
        
        (future ||| { (value: Int) -> Future<Int> in
            return Future<Int>(value * 2)
        }).subscribe { value in
            XCTAssertEqual(value, 2)
            exp.fulfill()
        }
        
        (delayContext(.milliseconds(100))) {
            future.resolve(with: 1)
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testFlatMapOperatorToDifferentType_OriginalFutureResolvedLately() {
        let exp = expectation(description: "Expect same value passed on to next future")
        let future = Future<Int>()
        
        let toHexStringFuture: (Int) -> Future<String> = { inValue in
            Future<String> { resolve in
                resolve(String(inValue, radix: 16, uppercase: true))
            }
        }
        
        (future ||| toHexStringFuture).subscribe { value in
            XCTAssertEqual(value, "F")
            exp.fulfill()
        }
        
        future.resolve(with: 15)
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    // MARK: - FlatMap Future being resolved lately
    
    func testFlatMapOperator_FlatMapFutureResolvedLately() {
        let exp = expectation(description: "Expect same value passed on to next future")
        let future = Future<Int>()
        
        (future ||| { (value: Int) -> Future<Int> in
            return Future<Int> { resolve in
                resolve(value * 2)
            }
        }).subscribe { value in
            XCTAssertEqual(value, 2)
            exp.fulfill()
        }
        
        future.resolve(with: 1)
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testFlatMapOperator_FlatMapFutureResolvedLatelyWithDelay() {
        let exp = expectation(description: "Expect same value passed on to next future")
        let future = Future<Int>()
        
        (future ||| { (value: Int) -> Future<Int> in
            return Future<Int> { resolve in
                resolve(value * 2)
            }
        }).subscribe { value in
            XCTAssertEqual(value, 2)
            exp.fulfill()
        }
        
        (delayContext(.milliseconds(100))) {
            future.resolve(with: 1)
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testFlatMapOperatorToDifferentType_FlatMapFutureResolvedLately() {
        let exp = expectation(description: "Expect same value passed on to next future")
        let future = Future<Int>()
        
        let toHexStringFuture: (Int) -> Future<String> = { inValue in
            Future<String> { resolve in
                resolve(String(inValue, radix: 16, uppercase: true))
            }
        }
        
        (future ||| toHexStringFuture).subscribe { value in
            XCTAssertEqual(value, "F")
            exp.fulfill()
        }
        
        future.resolve(with: 15)
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
