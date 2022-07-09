//
//  EmojiTests.swift
//  
//
//  Created by DariaMikots on 08.07.2022.
//
@testable import Networking
import XCTest

final class EmojiTests: XCTestCase {

    func testEmoji() async{
    let serviceMock = EmojiServiceMock()
        do {
            let emojies = try await serviceMock.getEmoji("smile", "100")
            XCTAssertEqual(emojies.results[0].emoji, "🍼")
        }
        catch {
            XCTFail("The request should not fail")
        }
    }
}
