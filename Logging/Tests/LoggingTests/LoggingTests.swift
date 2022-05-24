import XCTest
@testable import Logging

final class LoggingTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Logging().text, "Hello, World!")
    }
}
