//
//  FeatureInitWithResolver.swift
//  photonsTests
//
//  Created by Jun Meng on 19/5/20.
//

import XCTest
@testable import photons

class FutureInitResolverTests: XCTestCase {
    
    func testInitWithResolver() {
        let exp = expectation(description: "Expect resolved value will trigger completion closure")
        
        let future = Future<Int> { resolver in
            // As resolver is executed on default main thread, so it's main context
            XCTAssertTrue(Thread.current.isMainThread)
            resolver(10)
        }
        
        future.subscribe { value in
            // Default completion queue is on `mutex` queue
            XCTAssertFalse(Thread.current.isMainThread)
            XCTAssertEqual(value, 10, "Value should equal to resolved value")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 0.3) {
            if let error = $0 { XCTFail("Expectation not fulfilled. \(error)") }
        }
    }
    
    func testInitWithResolver_ResolveWithDelay() {
        let exp = expectation(description: "Expect resolved value will trigger completion closure")
        // Default thread is main thread
        XCTAssertTrue(Thread.current.isMainThread)
        
        let future = Future<Int> { resolver in
            (delayContext(.milliseconds(300))) {
                // As resolver is dispatched to `delayContext`, so it's no longer a `main` queue task
                XCTAssertFalse(Thread.current.isMainThread)
                resolver(10)
            }
        }
        
        future.subscribe { value in
            XCTAssertEqual(value, 10, "Value should equal to resolved value")
            // Default completion queue is on `mutex` queue
            XCTAssertFalse(Thread.current.isMainThread)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1) {
            if let error = $0 { XCTFail("Expectation not fulfilled. \(error)") }
        }
    }
    
    func testInitWithResolver_ResolveMultipleTimes() {
        let exp = expectation(description: "Expect last resolved value 20 will trigger completion closure once.")
        exp.expectedFulfillmentCount = 1
        // Default thread is main thread
        XCTAssertTrue(Thread.current.isMainThread)
        
        let future = Future<Int> { resolver in
            // AS resolve immediately when constructing a future, `completion` callback are not called due as which
            // is not attched to the future. When `completion` attaching to the future, only last value `20` will trigger it.
            resolver(10)
            resolver(20)
        }
        
        future.subscribe { value in
            XCTAssertEqual(value, 20, "Value should equal to resolved value")
            // Default completion queue is on `mutex` queue
            XCTAssertFalse(Thread.current.isMainThread)
            print("exp fulfill with \(value)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 2) {
            if let error = $0 { XCTFail("Expectation not fulfilled. \(error)") }
        }
    }
    
    func testInitWithResolver_ResolveMultipleTimesWithDelay() {
        let exp = expectation(description: "Expect last resolved value 20 will trigger completion closure once.")
        exp.expectedFulfillmentCount = 2
        // Default thread is main thread
        XCTAssertTrue(Thread.current.isMainThread)
        
        let future = Future<Int> { resolver in
            // AS resolve immediately when constructing a future, `completion` callback are not called due as which
            // is not attched to the future. When `completion` attaching to the future, only last value `20` will trigger it.
            (delayContext(.milliseconds(300))) {
                resolver(10)
                resolver(20)
            }
        }
        
        future.subscribe { value in
            // Default completion queue is on `mutex` queue
            XCTAssertFalse(Thread.current.isMainThread)
            print("exp fulfill with \(value)")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 2) {
            if let error = $0 { XCTFail("Expectation not fulfilled. \(error)") }
        }
    }
    
    func testInitWithResolver_ResolveWithNODelay_nilReferenceBeforeSubscribing() {
        let exp = expectation(description: "Expect resolved value will NOT trigger completion closure")
        exp.isInverted = true
        // Default thread is main thread
        XCTAssertTrue(Thread.current.isMainThread)
        
        var future: Future<Int>? = Future<Int> { resolver in
            XCTAssertTrue(Thread.current.isMainThread)
            resolver(10)
        }
        
        future = nil
        future?.subscribe { value in
            // Will not trigger this as future is deinited when `future = nil`
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1) {
            if let error = $0 { XCTFail("Expectation not fulfilled. \(error)") }
        }
    }
    
    func testInitWithResolver_ResolveWithDelay_nilReferenceBeforeSubscribing() {
        let exp = expectation(description: "Expect resolved value will NOT trigger completion closure")
        exp.isInverted = true
        // Default thread is main thread
        XCTAssertTrue(Thread.current.isMainThread)
        
        var future: Future<Int>? = Future<Int> { resolver in
            XCTAssertTrue(Thread.current.isMainThread)
            (delayContext(.milliseconds(300))) {
                // As resolver is dispatched to `delayContext`, so it's no longer a `main` queue task
                XCTAssertFalse(Thread.current.isMainThread)
                resolver(10)                
            }
        }
        future = nil
        future?.subscribe { value in
            // Will not trigger this as future is deinited when `future = nil`
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1) {
            if let error = $0 { XCTFail("Expectation not fulfilled. \(error)") }
        }
    }

    func testInitWithResolver_WithoutResolving() {
        let exp = expectation(description: "Expect resolved value will NOT trigger completion closure, as resolver is not called.")
        exp.isInverted = true
        // Default thread is main thread
        XCTAssertTrue(Thread.current.isMainThread)
        
        let future = Future<Int> { resolver in }
        
        future.subscribe { value in
            // Will not trigger this as future is deinited when `future = nil`
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1) {
            if let error = $0 { XCTFail("Expectation not fulfilled. \(error)") }
        }
    }
}
