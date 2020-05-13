import XCTest
@testable import photons

final class photonsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(photons().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
