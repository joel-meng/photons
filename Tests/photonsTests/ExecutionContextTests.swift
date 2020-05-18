//
//  ExecutionContextTests.swift
//  photonsTests
//
//  Created by Jun Meng on 15/5/20.
//

import XCTest
@testable import photons

class ExecutionContextTests: XCTestCase {

    func testTaskWithVoidInput() {
        expect("expect task run", { expectation in
            let task = Func<Void> { _ in
                expectation.fulfill()
            }
            task.execute(())
        })
    }

    func testTaskRunOnMain() {
        expect("expect task run on main", { expectation in
            // Run in a global queue to make sure not task is not accidentially run on main
            DispatchQueue.global().async {
                // Create a `Func` that running on `Main` thread.
                Func.main { value in
                    XCTAssertEqual(value, 1, "value is passed in value")
                    XCTAssertTrue(Thread.current.isMainThread)
                    expectation.fulfill()
                }.execute(1)
            }
        })
    }
    
    func testTaskRunOnBackground() {
        expect("expect task run on background", { expectation in
            // Run in a global queue to make sure not task is not accidentially run on background queue
            DispatchQueue.main.async {
                // Create a `Func` that running on background thread.
                Func.background { value in
                    XCTAssertEqual(value, 1, "value is passed in value")
                    XCTAssertFalse(Thread.current.isMainThread)
                    expectation.fulfill()
                }.execute(1)
            }
        })
    }
    
    func testTaskRunWithDelay() {
        let secondsOfDelay = 1
        expect("expect task run after a delay of \(secondsOfDelay)", { expectation in
            // Run in a global queue to make sure not task is not accidentially run on main
            DispatchQueue.global().async {
                // Create a `Func` that run with a expected delay thread.
                Func.delayed(for: .seconds(secondsOfDelay)) { value in
                    let executingTime = Date.timeIntervalSinceReferenceDate
                    XCTAssertGreaterThan(executingTime - value, TimeInterval(integerLiteral: Int64(secondsOfDelay)))
                    expectation.fulfill()
                }.execute(Date.timeIntervalSinceReferenceDate)
            }
        }, within: 5)
    }
    
    func testTaskRunWithAtomic() {
        var resource: [Int] = []
        expect("", { expectation in
            var fulfill1 = false
            var fulfill2 = false
            
            let task1 = Func<TimeInterval>.atomic { value in
                (0..<100).forEach {
                    Thread.sleep(forTimeInterval: value)
                    resource.append($0)
                }
                fulfill1 = true
                print(resource.count, "is main", Thread.current.isMainThread)
                resource = []
                if fulfill1 && fulfill2 {
                    expectation.fulfill()
                }
            }
            
            let task2 = Func<TimeInterval>.atomic { value in
                (100..<200).forEach {
                    Thread.sleep(forTimeInterval: value)
                    resource.append($0)
                }
                fulfill2 = true
                print(resource.count, "is main", Thread.current.isMainThread)
                resource = []
                if fulfill1 && fulfill2 {
                    expectation.fulfill()
                }
            }
            
            // Run in a global queue to make sure not task is not accidentially run on main
            DispatchQueue.global().async {
                task1.execute(0.01)
                task2.execute(0.02)
            }
        }, within: 20)
    }
}
