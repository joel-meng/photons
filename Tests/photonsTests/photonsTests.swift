import XCTest
@testable import photons

final class photonsTests: XCTestCase {
    
    func testSimpleFuture() {
        expect("Future<Int> should be invoked when value posted.", { (expectation) in
            let future = Future<Int>.pure { value in 
                XCTAssertEqual(value, 10)
                expectation.fulfill()
            }
            future.resolve(with: 10)
        })
    }
    
    func testHeavyLoadedFuture() {
        let queue = DispatchQueue.barrier
        var count = 0
        expect("Future<Int> should be invoked when value posted.", { (expectation) in
            let future = Future<Int>.pure { value in
                queue.async(flags: .barrier) {
                    count += 1
                    if value == 1000 {
                        expectation.fulfill()
                    }
                }
            }
            
            (1...1000).forEach {
                future.resolve(with: $0)
            }
        })
    }
    
    func testAsyncHeavyLoadedFuture() {
        let queue = DispatchQueue.barrier
        var count = 0
        expect("Future<Int> should be invoked when value posted.", { (expectation) in
            let future = Future<Int>.pure { value in
                queue.async(flags: .barrier) {
                    count += 1
                    if count == 10_000 {
                        expectation.fulfill()
                    }
                }
            }
            
            DispatchQueue.concurrentPerform(iterations: 10_000) {
                future.resolve(with: $0)
            }
        }, within: 1)
    }
    
    func testAsyncHeavyLoadedWithDelayFuture() {
        let queue = DispatchQueue.barrier
        var count = 0
        
        expect("Future<Int> should be invoked when value posted.", { (expectation) in
            let future = Future<Int>.pure { value in
                queue.async(flags: .barrier) {
                    count += 1
                    if count == 10_000 {
                        expectation.fulfill()
                    }
                }
            }
            
            DispatchQueue.concurrentPerform(iterations: 10_000) { value in
                let timeInterval = UInt8.random(in: 0...5)
                let dispatchTimeInterval: DispatchTimeInterval = .seconds(Int(timeInterval))
                DispatchQueue.background.asyncAfter(deadline: .now() + dispatchTimeInterval) {
                    future.resolve(with: value)
                }
            }
        }, within: 10)
    }

    static var allTests = [
        ("testSimpleFuture", testSimpleFuture),
        ("testHeavyLoadedFuture", testHeavyLoadedFuture),
        ("testAsyncHeavyLoadedFuture", testAsyncHeavyLoadedFuture),
        ("testAsyncHeavyLoadedWithDelayFuture", testAsyncHeavyLoadedWithDelayFuture),
    ]
}
