import XCTest
@testable import Parser

final class ParserTests: XCTestCase {


    static var allTests = [
        ("testExample", testExample),
    ]
    
    func testExample() {

        print(Error("Something went wrong"))
        print(Error("Something went wrong", 23, 42))
        print(Error("Something went wrong", node: Self.self))
        print(Error("Something went wrong", 23, node: Self.self))
        print(Error("Something went wrong", 23, 42, node: Self.self))
    }
    
}
