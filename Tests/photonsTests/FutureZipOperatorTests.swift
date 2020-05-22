//
//  FutureZipTests.swift
//  photonsTests
//
//  Created by Jun Meng on 22/5/20.
//

import XCTest
@testable import photons

class FutureZipOperatorTests: XCTestCase {
    
    func testZipOperator_FutureResolvedImmediately() {
        let exp = expectation(description: "2 futures are being resolved")
        // Immediate future init
        (Future(1) +++ Future(2)).onComplete { value in
            let (lhv, rhv) = value
            XCTAssertFalse(Thread.isMainThread, "completion default run on background queue")
            XCTAssertEqual(lhv, 1)
            XCTAssertEqual(rhv, 2)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testZipOperator_FutureResolvedWithResolverInit() {
        let exp = expectation(description: "2 futures are being resolved")

        // Future init with resolver
        let future1 = Future<Int> { resolve in
            resolve(1)
        }
        // Future init with resolver
        let future2 = Future<Int> { resolve in
            resolve(2)
        }
        
        (future1 +++ future2).onComplete { value in
            let (lhv, rhv) = value
            XCTAssertFalse(Thread.isMainThread, "completion default run on background queue")
            XCTAssertEqual(lhv, 1)
            XCTAssertEqual(rhv, 2)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testZipOperator_FutureResolvedWithResolverInit_AndDelayed() {
        let exp = expectation(description: "2 futures are being resolved")
        // Future init with resolver
        let future1 = Future<Int> { resolve in
            (delayContext(.milliseconds(200))) {
                resolve(1)
            }
        }
        // Future init with resolver
        let future2 = Future<Int> { resolve in
            (delayContext(.milliseconds(10))) {
                resolve(2)
            }
        }
        
        (future1 +++ future2).onComplete { value in
            let (lhv, rhv) = value
            XCTAssertFalse(Thread.isMainThread, "completion default run on background queue")
            XCTAssertEqual(lhv, 1)
            XCTAssertEqual(rhv, 2)
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testZipOperator_FutureResolvedAfterZipping() {
        // Future init with future resolving
        let future1 = Future<Int>()
        let future2 = Future<Int>()
        let exp = expectation(description: "2 futures are being resolved")
        
        (future1 +++ future2).onComplete { (value1, value2) in
            XCTAssertEqual(value1, 1, "Value1 should equal to 1")
            XCTAssertEqual(value2, 2, "Value2 should equal to 2")
            XCTAssertFalse(Thread.isMainThread, "completion default run on background queue")
            exp.fulfill()
        }
        
        (delayContext(.milliseconds(200))) {
            (delayContext(.milliseconds(100))) {
                future2.resolve(with: 2)
            }
            future1.resolve(with: 1)
        }
        waitForExpectations(timeout: 0.6, handler: nil)
    }
    
    // MARK: - Combination of different initilizer
    
    func testZipOperator_FutureResolvedZippingAndImmediateResolving() {
        // Future init with future resolving
        let future1 = Future<Int>()
        let exp = expectation(description: "2 futures are being resolved")
        
        // Immediate resolving on the right side of `+++`
        (future1 +++ Future(2)).onComplete { (value1, value2) in
            XCTAssertEqual(value1, 1, "Value1 should equal to 1")
            XCTAssertEqual(value2, 2, "Value2 should equal to 2")
            XCTAssertFalse(Thread.isMainThread, "completion default run on background queue")
            exp.fulfill()
        }
        
        (delayContext(.milliseconds(200))) {
            future1.resolve(with: 1)
        }
        waitForExpectations(timeout: 0.6, handler: nil)
    }
    
    func testZipOperator_FutureResolvedZippingAndImmediateResolving2() {
        // Future init with future resolving
        let future = Future<Int>()
        let exp = expectation(description: "2 futures are being resolved")
        
        // Immediate resolving on the left side of `+++`
        (Future(1) +++ future).onComplete { (value1, value2) in
            XCTAssertEqual(value1, 1, "Value1 should equal to 1")
            XCTAssertEqual(value2, 2, "Value2 should equal to 2")
            XCTAssertFalse(Thread.isMainThread, "completion default run on background queue")
            exp.fulfill()
        }
        
        (delayContext(.milliseconds(200))) {
            future.resolve(with: 2)
        }
        waitForExpectations(timeout: 0.6, handler: nil)
    }
    
    func testZipOperator_FutureResolvedZippingAndImmediateResolving3() {
        // Future init with future resolving
        let exp = expectation(description: "2 futures are being resolved")
        
        // Immediate resolving on the left side of `+++`
        (Future(1) +++ Future<Int> { resolve in
            resolve(2)
        }).onComplete { (value1, value2) in
            XCTAssertEqual(value1, 1, "Value1 should equal to 1")
            XCTAssertEqual(value2, 2, "Value2 should equal to 2")
            XCTAssertFalse(Thread.isMainThread, "completion default run on background queue")
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.6, handler: nil)
    }

    func testZipOperator_FutureResolvedZippingAndImmediateResolving4() {
        // Future init with future resolving
        let exp = expectation(description: "2 futures are being resolved")
        
        // Immediate resolving on the left side of `+++`
        (Future(1) +++ Future<Int> { resolve in
            (delayContext(.milliseconds(200))) {
                resolve(2)
            }
        }).onComplete { (value1, value2) in
            XCTAssertEqual(value1, 1, "Value1 should equal to 1")
            XCTAssertEqual(value2, 2, "Value2 should equal to 2")
            XCTAssertFalse(Thread.isMainThread, "completion default run on background queue")
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.6, handler: nil)
    }
}
