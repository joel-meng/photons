//
//  FutureMappingTest.swift
//  photonsTests
//
//  Created by Jun Meng on 13/5/20.
//

import XCTest
@testable import photons

class FutureMappingTest: XCTestCase {

    func testFutureMapWithInitialValue() {
        let future = Future<Int>(15)
        expect("future could map", { (expectation) in
            let mappedFuture = future.map {
                String.init($0, radix: 16, uppercase: true)
            }
            
            mappedFuture.onComplete { (result) in
                XCTAssertEqual(result, "F")
                expectation.fulfill()
            }
        })
    }
    
    func testFutureMapWithoutInitialValue() {
        let future = Future<Int>()
        expect("future could map", { (expectation) in
            let mappedFuture = future.map {
                String.init($0, radix: 16, uppercase: true)
            }
            
            mappedFuture.onComplete { (result) in
                XCTAssertEqual(result, "F")
                expectation.fulfill()
            }
            
            future.resolve(with: 15)
        })
    }
    
    func testFutureMapWithoutResolvingValue() {
        let future = Future<Int>()
        expect("that completion is not getting called.", { (expectation) in
            // Invert this expecation means expect the `fulfill` not getting called within time limit
            expectation.isInverted = true
            
            let mappedFuture = future.map {
                String.init($0, radix: 16, uppercase: true)
            }
            
            mappedFuture.onComplete { (result) in
                expectation.fulfill()
            }
        })
    }
    
    func testFutureFlatMap() {
        let future = Future<Int>()
        
        expect("future could flat map", { (expectation) in
            let mappedFuture = future.flatMap { int -> Future<String> in
                let innterFuture = Future<String> { resolve in
                    resolve(String(int, radix: 16, uppercase: true))
                }
                return innterFuture
            }
            mappedFuture.onComplete { (new) in
                XCTAssertEqual(new, "F")
                expectation.fulfill()
            }
            future.resolve(with: 15)
        }, within: 2)
     }
}
