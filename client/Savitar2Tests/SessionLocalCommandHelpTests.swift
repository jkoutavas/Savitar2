//
//  SessionLocalCommandHelpTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import XCTest

@testable import Savitar2

class SessionLocalCommandHelpTests: XCTestCase {
    func testParseHelpWithoutTopic() {
        XCTAssertEqual(SessionLocalCommands.parse("help"), .help(topic: nil))
    }

    func testParseHelpWithTopic() {
        XCTAssertEqual(SessionLocalCommands.parse("help upload"), .help(topic: "upload"))
        XCTAssertEqual(SessionLocalCommands.parse("help dump aliases"), .help(topic: "dump aliases"))
    }

    func testFullHelpHTMLUsesTappableCommandLinks() {
        let html = SessionLocalCommandHelp.html(marker: "##", topic: nil)
        XCTAssertTrue(html.contains("savitar-help-section"))
        XCTAssertTrue(html.contains("savitar-help-commands"))
        XCTAssertTrue(html.contains("xch_cmd=\"##help history\""))
        XCTAssertTrue(html.contains("class=\"savitar-help-cmd\""))
        XCTAssertFalse(html.contains("savitar-help-badge"))
        XCTAssertFalse(html.contains("Available"))
    }

    func testTopicHelpForCommandWithDetail() {
        let html = SessionLocalCommandHelp.html(marker: "##", topic: "link")
        XCTAssertTrue(html.contains("savitar-help-syntax-line"))
        XCTAssertTrue(html.contains("link &lt;url&gt;"))
        XCTAssertTrue(html.contains("Inserts a colored hyperlink"))
        XCTAssertTrue(html.contains("xch_cmd=\"##help\""))
        XCTAssertTrue(html.contains("savitar-help-back"))
    }

    func testTopicHelpForCaptureCommand() {
        let html = SessionLocalCommandHelp.html(marker: "##", topic: "capture")
        XCTAssertTrue(html.contains("capture"))
        XCTAssertTrue(html.contains("Toggles ad-hoc capture"))
        XCTAssertTrue(html.contains("World Settings"))
    }

    func testTopicHelpForUploadCommand() {
        let html = SessionLocalCommandHelp.html(marker: "##", topic: "upload")
        XCTAssertTrue(html.contains("upload"))
        XCTAssertTrue(html.contains("Sends a local text file"))
        XCTAssertTrue(html.contains("does not parse"))
    }

    func testTopicHelpForOpenTextWindowCommand() {
        let html = SessionLocalCommandHelp.html(marker: "##", topic: "open text window")
        XCTAssertTrue(html.contains("open text window"))
        XCTAssertTrue(html.contains("Opens a new untitled"))
    }

    func testTopicHelpForSendWindowCommand() {
        let html = SessionLocalCommandHelp.html(marker: "##", topic: "send window")
        XCTAssertTrue(html.contains("send window"))
        XCTAssertTrue(html.contains("Appends text"))
        XCTAssertTrue(html.contains("plain-text window"))
    }

    func testTopicHelpForDumpConnectionCommand() {
        let html = SessionLocalCommandHelp.html(marker: "##", topic: "dump connection")
        XCTAssertTrue(html.contains("dump connection"))
        XCTAssertTrue(html.contains("connection state"))
    }

    func testTopicHelpForPlayCommand() {
        let html = SessionLocalCommandHelp.html(marker: "##", topic: "play")
        XCTAssertTrue(html.contains("play"))
        XCTAssertTrue(html.contains("Audio Cue"))
    }

    func testTopicHelpForCommandWithoutDetail() {
        let html = SessionLocalCommandHelp.html(marker: "##", topic: "add world")
        XCTAssertTrue(html.contains("add world"))
        XCTAssertFalse(html.contains("savitar-help-detail-text"))
    }

    func testTopicHelpUnknownCommand() {
        let html = SessionLocalCommandHelp.html(marker: "##", topic: "xyzzy")
        XCTAssertTrue(html.contains("No help"))
        XCTAssertTrue(html.contains("savitar-help-back"))
    }

    func testHelpLinksProcessToSavitarXchURLs() {
        let html = SessionLocalCommandHelp.html(marker: "##", topic: nil)
        let processed = XchCmdLinkProcessor.process(html)
        XCTAssertTrue(processed.contains("savitar-xch:/"))
        XCTAssertTrue(processed.contains("help%20history") || processed.contains("help history"))
        guard let href = XchCmdLinkProcessor.hrefURL(for: "##help history"),
              let url = URL(string: href),
              let command = XchCmdLinkProcessor.command(from: url) else {
            return XCTFail("Expected savitar-xch URL for help drill-down")
        }
        XCTAssertEqual(command, "##help history")
    }
}
