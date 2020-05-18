//
//  FutureMappingTest.swift
//  photonsTests
//
//  Created by Jun Meng on 13/5/20.
//

import XCTest
@testable import photons

class FutureMappingTest: XCTestCase {
/*
    func testFutureMap() {
        
        expect("future could map", { (expectation) in
            let future = Future<Int>()
            let mappedFuture = future.map {
                String.init($0, radix: 16, uppercase: true)
            }
            
            mappedFuture.setComplete(AsyncTask<String> { (new) in
                XCTAssertEqual(new, "F")
                expectation.fulfill()
            })
            
            future.resolve(with: 15)
        })
    }
    
    func testFutureFlatMap() {
         
         expect("future could flat map", { (expectation) in
            let future = Future<Int>()
            future.resolve(with: 15)
            
            let innerFuture = Future<String>()
            
            let mappedFuture = future.flatMap { int -> Future<String> in
                print("--------\(int)------------")
                return innerFuture
            }
             
            mappedFuture.setComplete(AsyncTask<String> { (new) in
                XCTAssertEqual(new, "xxx")
                expectation.fulfill()
            })
             
            innerFuture.resolve(with: "xxx")
            
         }, within: 2)
     }
*/
}
