//
//  FutureMappingTest.swift
//  photonsTests
//
//  Created by Jun Meng on 13/5/20.
//

import XCTest
@testable import photons

class FutureMappingTest: XCTestCase {

    func testFutureMap() throws {
        
        expect("future could map", { (expectation) in
            let future = Future<Int>()
            let mappedFuture = future.map {
                String.init($0, radix: 16, uppercase: true)
            }
            
            mappedFuture.setComplete(AsyncTask<String>(task: { (new) in
                XCTAssertEqual(new, "F")
                expectation.fulfill()
            }))
            
            future.resolve(with: 15)
        })
    }
}
