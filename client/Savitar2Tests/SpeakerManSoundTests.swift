//
//  SpeakerManSoundTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import XCTest

@testable import Savitar2

class SpeakerManSoundTests: XCTestCase {
    private let names = ["Click", "Basso", "Pop", "Tink"]

    func testResolveSoundNameExactAndCaseInsensitive() {
        XCTAssertEqual(SpeakerMan.resolveSoundName("Basso", in: names), "Basso")
        XCTAssertEqual(SpeakerMan.resolveSoundName("basso", in: names), "Basso")
        XCTAssertEqual(SpeakerMan.resolveSoundName("Click", in: names), "Click")
    }

    func testResolveSoundNameStripsExtension() {
        XCTAssertEqual(SpeakerMan.resolveSoundName("Pop.aiff", in: names), "Pop")
        XCTAssertEqual(SpeakerMan.resolveSoundName("Tink.aif", in: names), "Tink")
    }

    func testResolveSoundNameUnknownReturnsNil() {
        XCTAssertNil(SpeakerMan.resolveSoundName("Nope", in: names))
        XCTAssertNil(SpeakerMan.resolveSoundName("", in: names))
    }
}
