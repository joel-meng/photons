import XCTest
@testable import photons

final class photonsTests: XCTestCase {
    
    func testFutureWithInitialValue() {
        let future = Future<Int>(2)
        expect("Future<Int> should be invoked when completion added", { (expectation) in
            future.onComplete { value in
                XCTAssertEqual(value, 2, "Must be the initial value")
                expectation.fulfill()
            }
        }, within: 1)
    }
    
    func testSimpleFuture() {
        let exp = expectation(description: "Should be resolved once")
        let future = Future<Int>.pure { value in
            XCTAssertEqual(value, 10)
            exp.fulfill()
        }
        future.resolve(with: 10)
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testResolvingFuture() {
        let exp = expectation(description: "Should be resolved 1_000 times")
        exp.expectedFulfillmentCount = 1000
        
        let future = Future<Int>.pure { value in
            XCTAssertEqual(value, 10)
            exp.fulfill()
        }
        
        (1...1000).forEach { _ in
            future.resolve(with: 10)
        }
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testMultithradResolvingFuture() {
        let exp = expectation(description: "Future<Int> completion should be invoked exactly the same time future resolving.")
        exp.expectedFulfillmentCount = 10000
        
        let future = Future<Int>.pure { value in
            XCTAssertEqual(value, 10)
            exp.fulfill()
        }
        
        DispatchQueue.concurrentPerform(iterations: 10_000) { y in
            future.resolve(with: 10)
        }
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testAsyncResolvingWithDelayFuture() {
        let exp = expectation(description: "Future<Int> completion should be invoked exactly the same time future resolving.")
        exp.expectedFulfillmentCount = 10_000
        
        let future = Future<Int>.pure { value in
            XCTAssertEqual(value, 10)
            exp.fulfill()
        }
        
        DispatchQueue.concurrentPerform(iterations: 10_000) { value in
            let timeInterval = UInt8.random(in: 0...5)
            let dispatchTimeInterval: DispatchTimeInterval = .seconds(Int(timeInterval))
            DispatchQueue.background.asyncAfter(deadline: .now() + dispatchTimeInterval) {
                future.resolve(with: 10)
            }
        }
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Multiple completion

    func testResolvingOnceWithManyCompletionFuture() {
        let exp = expectation(description: "Future<Int> with 10_000 completions should be invoked exactly 10_000 times.")
        exp.expectedFulfillmentCount = 10_000
        
        let future = Future<Int>()
        
        (0..<10_000).forEach { value in
            future.onComplete { value  in
                XCTAssertEqual(value, 100)
                exp.fulfill()
            }
        }
        
        future.resolve(with: 100)
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testResolvingOnceWhenConcurrentlyAddingCompletionFuture() {
        let exp = expectation(description: "Future<Int> with 10_000 completions should be invoked exactly 10_000 times.")
        exp.expectedFulfillmentCount = 10_000
        
        let future = Future<Int>()
        
        DispatchQueue.concurrentPerform(iterations: 10_000) { value in
            let timeInterval = UInt8.random(in: 0...5)
            let dispatchTimeInterval: DispatchTimeInterval = .seconds(Int(timeInterval))
            DispatchQueue.background.asyncAfter(deadline: .now() + dispatchTimeInterval) {
                future.onComplete { value in
                    XCTAssertEqual(value, 100)
                    exp.fulfill()
                }
            }
        }
        
        future.resolve(with: 100)
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testResolvingOnceInTheMiddleWhenConcurrentlyAddingCompletionFuture() {
        let exp = expectation(description: "Future<Int> with 10_000 completions should be invoked exactly 10_000 times.")
        exp.expectedFulfillmentCount = 10_000
        let queue = DispatchQueue.barrier
        var count = 0
        let future = Future<Int>()
        
        DispatchQueue.concurrentPerform(iterations: 10_000) { time in
            let timeInterval = UInt8.random(in: 0...5)
            let dispatchTimeInterval: DispatchTimeInterval = .seconds(Int(timeInterval))
            
            // resolve in the middle
            if time == 5_000 { future.resolve(with: 100) }
            
            DispatchQueue.background.asyncAfter(deadline: .now() + dispatchTimeInterval) {
                future.onComplete { value in
                    XCTAssertEqual(value, 100)
                    queue.async(flags: .barrier) {
                        count += 1
                        exp.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    // MARK: - Multi-Completion & Multi-Resolving
    
    func testResolvingTwiceOneInTheMiddleOfAddingCompletion_AndOneInCompletingOfAddingCompletion() {
        let exp = expectation(description: "Expect resolving value of 100 after completely adding completion should be exactly 1000 times of completion invocation.")
        exp.expectedFulfillmentCount = 10_000
        let future = Future<Int>()
        
        DispatchQueue.concurrentPerform(iterations: 10_000) { time in
            let timeInterval = UInt8.random(in: 0...10)
            let dispatchTimeInterval: DispatchTimeInterval = .milliseconds(Int(timeInterval))
            
            // resolve in the middle
            if time == 500 { future.resolve(with: 0) }
            
            DispatchQueue.background.asyncAfter(deadline: .now() + dispatchTimeInterval) {
                future.onComplete { value in
                    if value == 0 { return }
                    XCTAssertEqual(value, 100)
                    exp.fulfill()
                }
            }
        }
        
        future.resolve(with: 100)
        
        waitForExpectations(timeout: 30) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testResolvingMultipleTimesInTheMiddleOfAddingCompletion1() {
        let exp = expectation(description: "Expect latest resolved value will invoke 1_000 times")
        exp.expectedFulfillmentCount = 1_000
        
        let future = Future<Int>()
        
        (0..<1_000).forEach { time in
            if time == 50 { future.resolve(with: 0) }
            future.onComplete { value in
                guard value == 100 else { return }
                XCTAssertEqual(value, 100)
                exp.fulfill()
            }
        }
        
        future.resolve(with: 100)
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testResolvingMultipleTimesInTheMiddleOfAddingCompletion2() {
        let exp = expectation(description: "Expect value resolved in middle of adding completion will invoke less than 100 times")
        exp.expectedFulfillmentCount = 10_000
        let future = Future<Int>()
        
        (0..<10_000).forEach { time in
            if time == 10 { future.resolve(with: 0) }
            future.onComplete { value in
                guard value == 0 else { return }
                XCTAssertEqual(value, 0)
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    static var allTests = [
        ("testSimpleFuture", testSimpleFuture),
        ("testHeavyLoadedFuture", testResolvingFuture),
        ("testAsyncHeavyLoadedFuture", testMultithradResolvingFuture),
        ("testAsyncHeavyLoadedWithDelayFuture", testAsyncResolvingWithDelayFuture),
    ]
}
