//
//  OutputPlainTextTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa
import WebKit
import XCTest

@testable import Savitar2

class OutputPlainTextTests: XCTestCase {
    func testNewlineNormalization() {
        XCTAssertEqual(plain("a\r\nb\rc", html: false), "a\nb\nc")
        XCTAssertEqual(plain("a\r\nb\rc", html: true), "a\nb\nc")
    }

    func testLiteralPromptAndEntitiesStayWhenHTMLIsOff() {
        XCTAssertEqual(plain("<HP 100/100> hp>\r\n", html: false), "<HP 100/100> hp>\n")
        XCTAssertEqual(plain("<b>Hello</b> &amp; welcome\n", html: false), "<b>Hello</b> &amp; welcome\n")
        XCTAssertEqual(plain("a < b and <HP 100\n", html: false), "a < b and <HP 100\n")
    }

    func testHTMLOnStripsTagsAndDecodesEntities() {
        XCTAssertEqual(plain("<b>Hello</b> &amp; <i>welcome</i>\n", html: true), "Hello & welcome\n")
        XCTAssertEqual(plain("&lt;HP 100&gt;\n", html: true), "<HP 100>\n")
        XCTAssertEqual(plain("&AMP;", html: true), "&")
        XCTAssertEqual(plain("&nbsp;", html: true), "\u{00A0}")
        XCTAssertEqual(plain("&#65;&#x42;&#x3C;", html: true), "AB<")
        XCTAssertEqual(plain("A&nbsp;B", html: true), "A\u{00A0}B")
        XCTAssertEqual(plain("a  <b>b</b>", html: true), "a  b")
        XCTAssertEqual(plain("&notanentity; &amp", html: true), "&notanentity; &amp")
    }

    func testHTMLOnKeepsLinkTextAndDropsHref() {
        let link = "<a href=\"https://example.com/room\">north</a>\n"
        XCTAssertEqual(plain(link, html: true), "north\n")
        XCTAssertEqual(plain("<a href=\"a>b\">t</a>", html: true), "t")
        XCTAssertEqual(plain("<a xch_cmd=\"look\">look</a>", html: true), "look")
    }

    func testHTMLOnLineBreaks() {
        XCTAssertEqual(plain("Hello<br>there", html: true), "Hello\nthere")
        XCTAssertEqual(plain("Hello<br/>there", html: true), "Hello\nthere")
        XCTAssertEqual(plain("Hello<br />there", html: true), "Hello\nthere")
        XCTAssertEqual(plain("Hello<BR><br>there", html: true), "Hello\n\nthere")
        XCTAssertEqual(plain("<p>Hi</p><p>There</p>", html: true), "Hi\nThere\n")
        XCTAssertEqual(plain("Hello<p>there</p>", html: true), "Hello\nthere\n")
    }

    func testHTMLOnDropsCommentsScriptAndStyle() {
        let marked = "ok <!-- <b>no</b> --> <script>bad()</script><style>h1{}</style>yes"
        XCTAssertEqual(plain(marked, html: true), "ok  yes")
        XCTAssertEqual(plain("<SCRIPT>no</ScRiPt>yes", html: true), "yes")
        XCTAssertEqual(plain("<!DOCTYPE html>Hi", html: true), "Hi")
    }

    func testHTMLOnLeavesComparisonsAndUnclosedBrackets() {
        XCTAssertEqual(plain("a < b and <HP 100\n", html: true), "a < b and <HP 100\n")
        XCTAssertEqual(plain("<HP 100/100>\n", html: true), "\n")
        XCTAssertEqual(plain("HP <b>100</b>\n", html: true), "HP 100\n")
    }

    func testANSIStrippedForSpeechAndLoggingText() {
        let colored = "You see a \u{1B}[32mdragon\u{1B}[0m.\r\n"
        XCTAssertEqual(plain(colored, html: false), "You see a dragon.\n")
        XCTAssertEqual(plain(colored, html: true), "You see a dragon.\n")

        let mixed = "\u{1B}[1m<b>Hi</b>\u{1B}[0m &amp;\n"
        XCTAssertEqual(plain(mixed, html: false), "<b>Hi</b> &amp;\n")
        XCTAssertEqual(plain(mixed, html: true), "Hi &\n")
        XCTAssertEqual(plain("<\u{1B}[31mHP\u{1B}[0m 100>\n", html: false), "<HP 100>\n")
    }

    func testBackslashIsNotDoubled() {
        XCTAssertEqual(plain("C:\\temp\n", html: false), "C:\\temp\n")
    }

    func testPlainTextParseDoesNotConsumeCallerResumeBuffer() {
        var parser = Ansi2HtmlParser()
        _ = parser.parse(ansi: "\u{1B}[32", hideANSI: false)
        XCTAssertEqual(parser.buffer, "[32")

        let text = OutputPlainText.string(from: "mgreen\u{1B}[0m\n",
                                          interpretHTML: false,
                                          ansiParser: parser)
        XCTAssertEqual(text, "green\n")
        XCTAssertEqual(parser.buffer, "[32")

        let rendered = parser.parse(ansi: "mgreen\u{1B}[0m", hideANSI: false)
        XCTAssertEqual(rendered, "<span class='green '>green</span>")
        // A finished SGR stays in the resume buffer so the next read can replay it.
        XCTAssertEqual(parser.buffer, "[0m")
    }

    private func plain(_ text: String, html: Bool) -> String {
        return OutputPlainText.string(from: text, interpretHTML: html, ansiParser: Ansi2HtmlParser())
    }
}

private final class RecordingSpeakerMan: SpeakerMan {
    struct Utterance {
        var text: String
        var voiceName: String
    }

    var spoken: [Utterance] = []

    override func voiceNames() -> [String] {
        return ["Test Voice"]
    }

    override func resolvedContinuousSpeechVoiceName() -> String {
        return "Test Voice"
    }

    override func speak(text: String, voiceName: String) {
        spoken.append(Utterance(text: text, voiceName: voiceName))
    }
}

class OutputPlainTextPipelineTests: XCTestCase {
    private struct Sample {
        var input: String
        var interpretHTML: Bool
        var expected: String
    }

    private struct Delivery {
        var spoken: [String]
        var voiceNames: [String]
        var logged: String
        var captured: String
    }

    private let recorder = RecordingSpeakerMan()
    private var savedSpeaker: SpeakerMan?
    private var savedSpeechEnabled = false
    private var savedMuteSpeaking = false

    override func setUpWithError() throws {
        try super.setUpWithError()
        try XCTSkipUnless(AppContext.hasContinuousSpeech(),
                          "Continuous speech needs macOS 10.15 or later")
        savedSpeechEnabled = AppContext.shared.prefs.continuousSpeechEnabled
        savedMuteSpeaking = AppContext.shared.prefs.flags.contains(.muteSpeaking)
        savedSpeaker = AppContext.shared.speakerMan
        AppContext.shared.speakerMan = recorder
        AppContext.shared.appPrefsStore.dispatch(SetContinuousSpeechEnabledAction(true))
        AppContext.shared.appPrefsStore.dispatch(SetPrefsFlagAction(flag: .muteSpeaking, enabled: false))
    }

    override func tearDown() {
        if let savedSpeaker {
            AppContext.shared.appPrefsStore.dispatch(SetContinuousSpeechEnabledAction(savedSpeechEnabled))
            AppContext.shared.appPrefsStore.dispatch(SetPrefsFlagAction(flag: .muteSpeaking,
                                                                        enabled: savedMuteSpeaking))
            AppContext.shared.speakerMan = savedSpeaker
            self.savedSpeaker = nil
        }
        super.tearDown()
    }

    func testSpeechLoggingAndCaptureSharePlainText() throws {
        let samples = [
            Sample(input: "<b>Hello</b> &amp; welcome\n",
                   interpretHTML: true,
                   expected: "Hello & welcome\n"),
            Sample(input: "<b>Hello</b> &amp; welcome\n",
                   interpretHTML: false,
                   expected: "<b>Hello</b> &amp; welcome\n"),
            Sample(input: "You see a \u{1B}[32mdragon\u{1B}[0m.\r\n",
                   interpretHTML: false,
                   expected: "You see a dragon.\n"),
            Sample(input: "<HP 100/100>\r\n",
                   interpretHTML: false,
                   expected: "<HP 100/100>\n"),
            // HTML on treats "<HP …>" as a tag. SpeakerMan trims the remaining newline and stays silent.
            Sample(input: "<HP 100/100>\n",
                   interpretHTML: true,
                   expected: "\n")
        ]

        for sample in samples {
            for mode in ["off", "log", "capture", "both"] {
                let logging = mode == "log" || mode == "both"
                let capture = mode == "capture" || mode == "both"
                let delivery = try deliver(sample.input,
                                           useHTML: sample.interpretHTML,
                                           logging: logging,
                                           capture: capture)
                XCTAssertEqual(delivery.spoken, [sample.expected], mode)
                XCTAssertEqual(delivery.voiceNames, ["Test Voice"], mode)
                XCTAssertEqual(delivery.logged, logging ? sample.expected : "", mode)
                XCTAssertEqual(delivery.captured, capture ? sample.expected : "", mode)
            }
        }
    }

    func testMuteAndDisabledSpeechStillLogTheSamePlainText() throws {
        let input = "<b>Hello</b> &amp; welcome\n"
        let expected = "Hello & welcome\n"

        AppContext.shared.appPrefsStore.dispatch(SetPrefsFlagAction(flag: .muteSpeaking, enabled: true))
        let muted = try deliver(input, useHTML: true, logging: true)
        XCTAssertEqual(muted.spoken, [])
        XCTAssertEqual(muted.logged, expected)

        AppContext.shared.appPrefsStore.dispatch(SetPrefsFlagAction(flag: .muteSpeaking, enabled: false))
        AppContext.shared.appPrefsStore.dispatch(SetContinuousSpeechEnabledAction(false))
        let disabled = try deliver(input, useHTML: true, logging: true)
        XCTAssertEqual(disabled.spoken, [])
        XCTAssertEqual(disabled.logged, expected)
    }

    func testSkipCaptureExcludesCaptureOnly() throws {
        recorder.spoken.removeAll()
        let outputView = makeOutputView(useHTML: true)
        let logURL = tempFile()
        let captureURL = tempFile()
        defer {
            try? FileManager.default.removeItem(at: logURL)
            try? FileManager.default.removeItem(at: captureURL)
        }
        beginLogging(outputView, at: logURL.path)
        XCTAssertTrue(outputView.startCapture(at: captureURL.path))

        outputView.output(string: "[SAVITAR] Capture started.\n", skipCapture: true)
        outputView.output(string: "<b>Room</b>\n", skipCapture: false)

        endLogging(outputView)
        _ = outputView.stopCapture()

        let logged = try String(contentsOf: logURL, encoding: .utf8)
        let captured = try String(contentsOf: captureURL, encoding: .utf8)
        XCTAssertEqual(logged, "[SAVITAR] Capture started.\nRoom\n")
        XCTAssertEqual(captured, "Room\n")
        XCTAssertEqual(recorder.spoken.map(\.text), ["[SAVITAR] Capture started.\n", "Room\n"])
    }

    func testSplitAnsiResumeSurvivesPlainTextGeneration() throws {
        recorder.spoken.removeAll()
        let outputView = makeOutputView(useHTML: false)
        outputView.output(string: "\u{1B}[32")
        XCTAssertEqual(outputView.ansiToHtml.buffer, "[32")

        outputView.output(string: "mgreen\u{1B}[0m\n")
        XCTAssertEqual(outputView.ansiToHtml.buffer, "[0m")
        XCTAssertEqual(recorder.spoken.map(\.text), ["", "green\n"])
    }

    func testEchoBackKeepsLiteralTextAndSessionAnsiState() throws {
        recorder.spoken.removeAll()
        let outputView = makeOutputView(useHTML: true)
        let logURL = tempFile()
        defer { try? FileManager.default.removeItem(at: logURL) }
        beginLogging(outputView, at: logURL.path)

        outputView.output(string: "\u{1B}[32")
        outputView.outputEchoBack(string: "\u{1B}[31m<HP 9>\u{1B}[0m\n")
        XCTAssertEqual(outputView.ansiToHtml.buffer, "[32")

        outputView.output(string: "mgreen\n")
        endLogging(outputView)

        let logged = try String(contentsOf: logURL, encoding: .utf8)
        XCTAssertEqual(logged, "<HP 9>\ngreen\n")
        XCTAssertEqual(recorder.spoken.map(\.text), ["", "green\n"])
        XCTAssertEqual(outputView.ansiToHtml.buffer, "[32m")
    }

    func testANSIOffAndBellStillProducePlainSpeech() throws {
        let wasMuted = AppContext.shared.prefs.flags.contains(.muteBell)
        AppContext.shared.appPrefsStore.dispatch(SetPrefsFlagAction(flag: .muteBell, enabled: true))
        defer {
            AppContext.shared.appPrefsStore.dispatch(SetPrefsFlagAction(flag: .muteBell, enabled: wasMuted))
        }

        let colored = try deliver("\u{1B}[32mgreen\u{1B}[0m\n", useHTML: false, logging: true, useANSI: false)
        XCTAssertEqual(colored.spoken, ["green\n"])
        XCTAssertEqual(colored.logged, "green\n")

        let bell = try deliver("Hi\u{7} there\r\n", useHTML: false, logging: true)
        XCTAssertEqual(bell.spoken, ["Hi there\n"])
        XCTAssertEqual(bell.logged, "Hi there\n")
        XCTAssertFalse(bell.logged.contains("\u{7}"))
    }

    private func deliver(_ text: String,
                         useHTML: Bool,
                         logging: Bool = false,
                         capture: Bool = false,
                         skipCapture: Bool = false,
                         useANSI: Bool = true) throws -> Delivery {
        recorder.spoken.removeAll()
        let outputView = makeOutputView(useHTML: useHTML, useANSI: useANSI)
        let logURL = tempFile()
        let captureURL = tempFile()
        defer {
            try? FileManager.default.removeItem(at: logURL)
            try? FileManager.default.removeItem(at: captureURL)
        }
        if logging {
            beginLogging(outputView, at: logURL.path)
        }
        if capture {
            XCTAssertTrue(outputView.startCapture(at: captureURL.path))
        }
        outputView.output(string: text, skipCapture: skipCapture)
        if logging {
            endLogging(outputView)
        }
        if capture {
            _ = outputView.stopCapture()
        }
        let logged = logging ? try String(contentsOf: logURL, encoding: .utf8) : ""
        let captured = capture ? try String(contentsOf: captureURL, encoding: .utf8) : ""
        return Delivery(spoken: recorder.spoken.map(\.text),
                        voiceNames: recorder.spoken.map(\.voiceName),
                        logged: logged,
                        captured: captured)
    }

    private func makeOutputView(useHTML: Bool, useANSI: Bool = true) -> OutputView {
        let outputView = OutputView(frame: .zero, configuration: WKWebViewConfiguration())
        outputView.useHTML = useHTML
        outputView.useANSI = useANSI
        return outputView
    }

    private func tempFile() -> URL {
        return FileManager.default.temporaryDirectory
            .appendingPathComponent("Savitar2Plain-\(UUID().uuidString).log")
    }

    private func beginLogging(_ outputView: OutputView, at path: String) {
        let world = World()
        world.loggingEnabled = true
        world.logfilePath = path
        world.loggingType = .overwrite
        outputView.setLogging(world: world)
    }

    private func endLogging(_ outputView: OutputView) {
        outputView.setLogging(world: World())
    }
}
