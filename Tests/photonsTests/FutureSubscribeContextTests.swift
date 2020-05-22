//
//  FutureSubscribeContextTests.swift
//  photonsTests
//
//  Created by Jun Meng on 20/5/20.
//

import XCTest
@testable import photons

class FutureSubscriptionContextTests: XCTestCase {

    // MARK: - Subcribe without assign a subscription context
    
    func testSubscribeOnCurrentContext() {
        let future = Future<Int>()
        let exp = expectation(description: "future's completion will be invoked on current context")
        
        future.onComplete { value in
            XCTAssertFalse(Thread.current.isMainThread, "Default is the mutex background queue")
            exp.fulfill()
        }
        
        future.resolve(with: 1)
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testSubscribeOnMainContext() {
        let future = Future<Int>()
        let exp = expectation(description: "future's completion will be invoked on main context")
        future.onComplete(subscribeOn: mainContext) { value in
            XCTAssertTrue(Thread.current.isMainThread, "Subscribe on `mainContext`")
            exp.fulfill()
        }
        
        future.resolve(with: 1)
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testSubscribeOnBackgroundContext() {
        let future = Future<Int>()
        let exp = expectation(description: "future's completion will be invoked on main context")
        
        future.onComplete(subscribeOn: backgroundContext) { value in
            XCTAssertFalse(Thread.current.isMainThread, "Subscribe on `mainContext`")
            exp.fulfill()
        }
        
        future.resolve(with: 1)
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    // MARK: - Future is resolved immediately after creating, but subscription still run on subscription queue.
    
    func testSubscribeOnMainContextEvenFutureBeingResolvedBeforeSubscription() {
        let future = Future<Int> { resolver in
            resolver(1)
        }
        
        let exp = expectation(description: "future's completion will be invoked on main context")
        
        future.onComplete(subscribeOn: mainContext) { value in
            XCTAssertTrue(Thread.current.isMainThread, "Subscribe on `mainContext`")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testSubscribeOnMainContextEvenFutureBeingResolvedBeforeSubscription2() {
        let future = Future<Int>(1)
        
        let exp = expectation(description: "future's completion will be invoked on main context")
        
        future.onComplete(subscribeOn: mainContext) { value in
            XCTAssertTrue(Thread.current.isMainThread, "Subscribe on `mainContext`")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
