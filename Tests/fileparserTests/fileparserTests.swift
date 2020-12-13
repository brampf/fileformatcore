import XCTest
@testable import fileparser

final class fileparserTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(fileparser().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
