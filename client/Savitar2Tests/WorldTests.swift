//
//  WorldTests.swift
//  Savitar2Tests
//
//  Created by Jay Koutavas on 12/15/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Cocoa
import SwiftyXMLParser
import WebKit
import XCTest

@testable import Savitar2

class WorldTests: XCTestCase {
    func testv1WorldXMLtoV2() throws {
        // v1 XML
        let xmlInString = """
        <WORLD
            NAME="Alter Aeon"
            URL="telnet://dentinmud.org:3000"
            FLAGS="html+ansi"
            CMDMARKER="##"
            VARMARKER="%%"
            WILDMARKER="$$"
            FORECOLOR="#FFFFFF"
            BACKCOLOR="#666699"
            LINKCOLOR="#9CA6FF"
            ECHOBGCOLOR="#FFF88F"
            INTENSECOLOR="#FFFFFF"
            INTENSETYPE="0"
            FONT="Monaco"
            FONTSIZE="9"
            MONO="Monaco"
            MONOSIZE="9"
            MCPFONT="Monaco"
            MCPFONTSIZE="9"
            RESOLUTION="80x24x2"
            POSITION="50,50"
            WINDOWSIZE="0,0"
            ZOOMED="FALSE"
            OUTPUTMAX="102400"
            OUTPUTMIN="25600"
            FLUSHTICKS="30"
            RETRYSECS="0"
            KEEPALIVEMINS="0"
        />
        """

        let xml = try XML.parse(xmlInString)
        let w1 = World()
        try w1.parse(xml: xml[WorldElemIdentifier])

        let xmlOutString = try w1.toXMLElement().xmlString.prettyXMLFormat()

        // v2 XML
        let expectedOutput = """
        <?xml version="1.0" encoding="UTF-8"?>
        <WORLD URL="telnet://dentinmud.org:3000" NAME="Alter Aeon" FLAGS="ansi+html" CMDMARKER="##" VARMARKER="%%" WILDMARKER="$$" FORECOLOR="#FFFFFF" BACKCOLOR="#666699" LINKCOLOR="#9CA6FF" ECHOBGCOLOR="#FFF88F" INTENSECOLOR="#FFFFFF" FONT="Monaco" FONTSIZE="9" MONO="Monaco" MONOSIZE="9" MCPFONT="Monaco" MCPFONTSIZE="9" RESOLUTION="80x24x2" POSITION="50,50" WINDOWSIZE="0,0" ZOOMED="FALSE" OUTPUTMAX="102400" OUTPUTMIN="25600" FLUSHTICKS="30" RETRYSECS="0" KEEPALIVEMINS="0" LOGFILEPATH="" LOGGINGENABLED="FALSE" LOGGINGTYPE="append"></WORLD>
        """

        XCTAssertEqual(xmlOutString, expectedOutput)

        XCTAssertEqual(w1.triggerMan.get().count, 0)

        XCTAssertEqual(w1.macroMan.get().count, 0)
    }

    func testv1WorldXMLWithTriggersToV2() throws {
        // v1 XML
        let xmlInString = """
        <WORLD
            NAME="Alter Aeon"
            URL="telnet://dentinmud.org:3000"
            FLAGS="html+ansi"
            CMDMARKER="##"
            VARMARKER="%%"
            WILDMARKER="$$"
            FORECOLOR="#FFFFFF"
            BACKCOLOR="#666699"
            LINKCOLOR="#9CA6FF"
            ECHOBGCOLOR="#FFF88F"
            INTENSECOLOR="#FFFFFF"
            INTENSETYPE="0"
            FONT="Monaco"
            FONTSIZE="9"
            MONO="Monaco"
            MONOSIZE="9"
            MCPFONT="Monaco"
            MCPFONTSIZE="9"
            RESOLUTION="80x24x2"
            POSITION="50,50"
            WINDOWSIZE="0,0"
            ZOOMED="FALSE"
            OUTPUTMAX="102400"
            OUTPUTMIN="25600"
            FLUSHTICKS="30"
            RETRYSECS="0"
            KEEPALIVEMINS="0">
            <LOGONCMD>connect spinlock fnordy\nwho</LOGONCMD>
            <LOGOFFCMD>@quit</LOGOFFCMD>
            <TRIGGERS>
                <TRIGGER
                    NAME="^joan"
                    TYPE="output"
                    FLAGS="matchWholeLine+useRegex"
                    COLOR="#EE42BB"
                    AUDIO="speakEvent"
                    SOUND="Click"
                    VOICE="Princess">
                    <WORDEND>
                        &amp;-&quot;
                    </WORDEND>
                    <SAY>
                         Select a voice from the menu to hear this.
                    </SAY>
                </TRIGGER>
            </TRIGGERS>
        </WORLD>
        """

        let xml = try XML.parse(xmlInString)
        let w1 = World()
        try w1.parse(xml: xml[WorldElemIdentifier])

        let xmlOutString = try w1.toXMLElement().xmlString.prettyXMLFormat()

        // v2 XML
        let expectedOutput = """
        <?xml version="1.0" encoding="UTF-8"?>
        <WORLD URL="telnet://dentinmud.org:3000" NAME="Alter Aeon" FLAGS="ansi+html" CMDMARKER="##" VARMARKER="%%" WILDMARKER="$$" FORECOLOR="#FFFFFF" BACKCOLOR="#666699" LINKCOLOR="#9CA6FF" ECHOBGCOLOR="#FFF88F" INTENSECOLOR="#FFFFFF" FONT="Monaco" FONTSIZE="9" MONO="Monaco" MONOSIZE="9" MCPFONT="Monaco" MCPFONTSIZE="9" RESOLUTION="80x24x2" POSITION="50,50" WINDOWSIZE="0,0" ZOOMED="FALSE" OUTPUTMAX="102400" OUTPUTMIN="25600" FLUSHTICKS="30" RETRYSECS="0" KEEPALIVEMINS="0" LOGFILEPATH="" LOGGINGENABLED="FALSE" LOGGINGTYPE="append">
            <LOGONCMD>connect spinlock fnordy\nwho</LOGONCMD>
            <LOGOFFCMD>@quit</LOGOFFCMD>
            <TRIGGERS>
                <TRIGGER NAME="^joan" TYPE="output" FLAGS="matchWholeLine+useRegex" FACE="foreColor" FGCOLOR="#EE42BB" SOUND="Click" AUDIO="speakEvent" VOICE="Princess">
                    <WORDEND>&amp;-"</WORDEND>
                    <SAY>Select a voice from the menu to hear this.</SAY>
                </TRIGGER>
            </TRIGGERS>
        </WORLD>
        """

        XCTAssertEqual(xmlOutString, expectedOutput)
    }

    func testCommandMarkerRoundTripsThroughXML() throws {
        let xmlString = """
        <WORLD
            NAME="Alter Aeon"
            URL="telnet://dentinmud.org:3000"
            CMDMARKER="//"
        />
        """

        let xml = try XML.parse(xmlString)
        let world = World()
        try world.parse(xml: xml[WorldElemIdentifier])

        XCTAssertEqual(world.cmdMarker, "//")

        let xmlOutString = try world.toXMLElement().xmlString.prettyXMLFormat()
        XCTAssertTrue(xmlOutString.contains("CMDMARKER=\"//\""))
    }

    func testStartingConnectionSettingsRoundTripThroughXML() throws {
        let xmlString = """
        <WORLD
            NAME="Alter Aeon"
            URL="telnet://dentinmud.org:3000"
            RETRYSECS="45"
            KEEPALIVEMINS="3"
        />
        """

        let xml = try XML.parse(xmlString)
        let world = World()
        try world.parse(xml: xml[WorldElemIdentifier])

        XCTAssertEqual(world.retrySecs, 45)
        XCTAssertEqual(world.keepAliveMins, 3)

        let xmlOutString = try world.toXMLElement().xmlString.prettyXMLFormat()
        XCTAssertTrue(xmlOutString.contains("RETRYSECS=\"45\""))
        XCTAssertTrue(xmlOutString.contains("KEEPALIVEMINS=\"3\""))
    }

    func testStickyCommandsRoundTripThroughXML() throws {
        let xmlString = """
        <WORLD
            NAME="Alter Aeon"
            URL="telnet://dentinmud.org:3000"
            FLAGS="html+ansi+stickyCmds"
        />
        """

        let xml = try XML.parse(xmlString)
        let world = World()
        try world.parse(xml: xml[WorldElemIdentifier])

        XCTAssertTrue(world.flags.contains(.stickyCmds))

        let xmlOutString = try world.toXMLElement().xmlString.prettyXMLFormat()
        XCTAssertTrue(xmlOutString.contains("FLAGS=\"ansi+html+stickyCmds\""))
    }

    func testCROnlyFlagRoundTripThroughXML() throws {
        let xmlString = """
        <WORLD
            NAME="Alter Aeon"
            URL="telnet://dentinmud.org:3000"
            FLAGS="html+ansi+CROnly"
        />
        """

        let xml = try XML.parse(xmlString)
        let world = World()
        try world.parse(xml: xml[WorldElemIdentifier])

        XCTAssertTrue(world.flags.contains(.crOnly))
        XCTAssertEqual(world.commandLinePostfix, "\r")

        let xmlOutString = try world.toXMLElement().xmlString.prettyXMLFormat()
        XCTAssertTrue(xmlOutString.contains("FLAGS=\"ansi+html+CROnly\""))
    }

    func testAutoCloseFlagRoundTripThroughXML() throws {
        let xmlString = """
        <WORLD
            NAME="Alter Aeon"
            URL="telnet://example.com:3000"
            FLAGS="html+ansi+autoClose"
            CMDMARKER="##"
            VARMARKER="%%"
            WILDMARKER="$$"
            RESOLUTION="80x24x2"
        />
        """

        let xml = try XML.parse(xmlString)
        let world = World()
        try world.parse(xml: xml[WorldElemIdentifier])

        XCTAssertTrue(world.flags.contains(.autoClose))

        let xmlOutString = try world.toXMLElement().xmlString
        XCTAssertTrue(xmlOutString.contains("autoClose"))
    }

    func testCommandLinePostfixDefaultsToCRLF() {
        let world = World()
        XCTAssertEqual(world.commandLinePostfix, "\r\n")
    }

    func testMarkerRoundTripThroughXML() throws {
        let xmlString = """
        <WORLD
            NAME="Alter Aeon"
            URL="telnet://dentinmud.org:3000"
            FLAGS="html+ansi"
            CMDMARKER="@@"
            VARMARKER="nm"
            WILDMARKER="??"
        />
        """

        let xml = try XML.parse(xmlString)
        let world = World()
        try world.parse(xml: xml[WorldElemIdentifier])

        XCTAssertEqual(world.cmdMarker, "@@")
        XCTAssertEqual(world.varMarker, "nm")
        XCTAssertEqual(world.wildMarker, "??")

        let xmlOutString = try world.toXMLElement().xmlString.prettyXMLFormat()
        XCTAssertTrue(xmlOutString.contains("CMDMARKER=\"@@\""))
        XCTAssertTrue(xmlOutString.contains("VARMARKER=\"nm\""))
        XCTAssertTrue(xmlOutString.contains("WILDMARKER=\"??\""))
    }
}

private class MockSessionHandler: SessionHandlerProtocol {
    var outputs: [String] = []
    var errors: [String] = []
    var printedSource = false
    var history: [String] = []
    var statuses: [(pane: SessionStatusPane, text: String)] = []
    var closedStatusBars = false
    var closedStatusPanes: [SessionStatusPane] = []
    var recalledIndex: Int?
    var clearedOutput = false
    var refreshedDisplay = false
    var worldTriggerList: [Trigger] = []
    var worldMacroList: [Macro] = []
    var capturing = false
    var capturePath: String?
    var htmlOutputs: [(html: String, skipCapture: Bool)] = []

    func connectionStatusChanged(status _: ConnectionStatus) {}

    func output(result: OutputResult, skipCapture _: Bool) {
        switch result {
        case let .success(output):
            outputs.append(output)
        case let .error(error):
            errors.append(error)
        }
    }

    func printSource() {
        printedSource = true
    }

    func commandHistory() -> [String] {
        return history
    }

    func setSessionStatus(pane: SessionStatusPane, text: String) {
        statuses.append((pane: pane, text: text))
    }

    func closeSessionStatusBars() {
        closedStatusBars = true
    }

    func closeSessionStatus(pane: SessionStatusPane) {
        closedStatusPanes.append(pane)
    }

    func recallCommand(at index: Int) {
        recalledIndex = index
    }

    func clearOutputScreen() {
        clearedOutput = true
    }

    func refreshSessionDisplay() {}

    func worldTriggers() -> [Trigger] {
        return worldTriggerList
    }

    func worldMacros() -> [Macro] {
        return worldMacroList
    }

    var isSessionCapturing: Bool {
        return capturing
    }

    func beginSessionCapture() -> SessionCaptureBeginResult {
        capturing = true
        capturePath = "/tmp/test-capture.txt"
        return .started(path: capturePath!)
    }

    func stopSessionCapture() -> String? {
        capturing = false
        return capturePath
    }

    func outputHTML(_ html: String, skipCapture: Bool) {
        htmlOutputs.append((html: html, skipCapture: skipCapture))
    }
}

class SessionLocalCommandTests: XCTestCase {
    func testHistoryCommandPrintsCommandHistory() {
        let world = World()
        let handler = MockSessionHandler()
        handler.history = ["look", "say hello", "##history"]
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "##history"))

        XCTAssertEqual(handler.outputs, [
            "[SAVITAR] Command history:\n1  look\n2  say hello\n3  ##history\n"
        ])
        XCTAssertTrue(handler.errors.isEmpty)
        XCTAssertFalse(handler.printedSource)
    }

    func testHistoryCommandUsesWorldCommandMarker() {
        let world = World()
        world.cmdMarker = "//"
        let handler = MockSessionHandler()
        handler.history = ["//history"]
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "//history"))

        XCTAssertEqual(handler.outputs, ["[SAVITAR] Command history:\n1  //history\n"])
    }

    func testDumpCommandUsesLocalCommandDispatcher() {
        let world = World()
        let handler = MockSessionHandler()
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "##dump"))

        XCTAssertTrue(handler.printedSource)
        XCTAssertTrue(handler.outputs.isEmpty)
    }

    func testLocalCommandExpandsV1VariablesBeforeDispatch() {
        let world = World()
        world.variableMan.set("cmd", value: "##history")
        let handler = MockSessionHandler()
        handler.history = ["look", "%%cmd"]
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "%%cmd"))

        XCTAssertEqual(handler.outputs, [
            "[SAVITAR] Command history:\n1  look\n2  %%cmd\n"
        ])
    }

    func testSetStatusCommandUpdatesSessionStatus() {
        let world = World()
        let handler = MockSessionHandler()
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "##set status output Hello world"))

        XCTAssertEqual(handler.statuses.count, 1)
        XCTAssertEqual(handler.statuses.first?.pane, .output)
        XCTAssertEqual(handler.statuses.first?.text, "Hello world")
    }

    func testCloseStatsCommandClosesStatusBars() {
        let world = World()
        let handler = MockSessionHandler()
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "##close stats"))

        XCTAssertTrue(handler.closedStatusBars)
    }

    func testCloseStatusOutputCommandClosesOnePane() {
        let world = World()
        let handler = MockSessionHandler()
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "##close status output"))

        XCTAssertEqual(handler.closedStatusPanes, [.output])
    }

    func testClearScreenCommandClearsOutput() {
        let world = World()
        let handler = MockSessionHandler()
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "##clear screen"))

        XCTAssertTrue(handler.clearedOutput)
    }

    func testCaptureCommandStartsAndStopsCapture() {
        let world = World()
        let handler = MockSessionHandler()
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "##capture"))

        XCTAssertTrue(handler.capturing)
        XCTAssertEqual(handler.htmlOutputs.count, 1)
        XCTAssertTrue(handler.htmlOutputs[0].skipCapture)
        XCTAssertTrue(handler.htmlOutputs[0].html.contains("Capture started."))
        XCTAssertTrue(handler.htmlOutputs[0].html.contains("Saving to"))
        XCTAssertTrue(handler.htmlOutputs[0].html.contains("savitar-file://"))
        XCTAssertTrue(handler.htmlOutputs[0].html.contains("/tmp/test-capture.txt"))
        XCTAssertTrue(handler.outputs.isEmpty)

        session.submitServerCmd(cmd: Command(text: "##capture"))

        XCTAssertFalse(handler.capturing)
        XCTAssertEqual(handler.htmlOutputs.count, 2)
        XCTAssertTrue(handler.htmlOutputs[1].html.contains("Capture stopped."))
        XCTAssertTrue(handler.htmlOutputs[1].html.contains("Saved to"))
    }

    func testRecallCommandRecallsHistoryEntry() {
        let world = World()
        let handler = MockSessionHandler()
        handler.history = ["look", "say hi"]
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "##recall 2"))

        XCTAssertEqual(handler.recalledIndex, 2)
    }

    func testSetAnsiFlagCommand() {
        let world = World()
        let handler = MockSessionHandler()
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "##set ansi on"))

        XCTAssertTrue(session.world.flags.contains(.ansi))
    }

    func testSetScratchVariableCommand() {
        let world = World()
        let handler = MockSessionHandler()
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "##set macro \"hp\" 42"))

        XCTAssertEqual(session.world.variableMan.get("hp"), "42")
    }

    func testRegexCommandSetsCaptureVariables() {
        let world = World()
        let handler = MockSessionHandler()
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "##regex \"abc123\" \"abc([0-9]+)\""))

        XCTAssertEqual(session.world.variableMan.get("0"), "abc123")
        XCTAssertEqual(session.world.variableMan.get("1"), "123")
        XCTAssertTrue(handler.outputs.first?.contains("success") ?? false)
    }

    func testDumpTriggersUsesLiveWorldTriggerList() {
        let world = World()
        let handler = MockSessionHandler()
        let trigger = Trigger(name: "Gag spam", flags: .gag)
        handler.worldTriggerList = [trigger]
        let session = Session(world: world, sessionHandler: handler)

        session.submitServerCmd(cmd: Command(text: "##dump triggers"))

        XCTAssertTrue(handler.outputs.first?.contains("Gag spam") ?? false)
        XCTAssertTrue(handler.outputs.first?.contains("&lt;TRIGGER") ?? false)
        XCTAssertFalse(handler.outputs.first?.contains("&lt;?xml") ?? true)
    }
}

class InputTriggerVariableTests: XCTestCase {
    func testInputTriggerSetsVariableForReplyExpansion() {
        let world = World()
        let handler = MockSessionHandler()
        handler.history = ["set ##history"]
        let session = Session(world: world, sessionHandler: handler)
        let trigger = Trigger(name: "set $$cmd", flags: .gag, type: .input, reply: "%%cmd")
        world.triggerMan.add(trigger)

        var line = "set ##history"
        let effects = session.determineEffects(line: &line, excludedType: .output)

        XCTAssertEqual(line, "")
        XCTAssertEqual(effects, [trigger])
        XCTAssertEqual(world.variableMan.get("cmd"), "##history")

        session.handleEffects(effects)

        XCTAssertEqual(handler.outputs, [
            "[SAVITAR] Command history:\n1  set ##history\n"
        ])
    }
}

class StickyCommandInputTests: XCTestCase {
    func testTypingOverStickyCommandStartsFreshHistorySlot() {
        let world = World()
        world.flags.insert(.stickyCmds)
        let handler = MockSessionHandler()
        let inputController = InputViewController()
        inputController.textView = NSTextView()
        let session = Session(world: world, sessionHandler: handler)
        inputController.session = session
        inputController.newCmd()

        inputController.textView.string = "look"
        inputController.cmdIndex = inputController.cmdBuf.count
        XCTAssertTrue(inputController.saveCmd())

        inputController.textView.selectAll(nil)
        inputController.stickyGotSaved = true

        let shouldChange = inputController.textView(inputController.textView,
                                                    shouldChangeTextIn: NSRange(location: 0, length: 4),
                                                    replacementString: "say")

        XCTAssertFalse(shouldChange)
        XCTAssertEqual(inputController.textView.string, "say")
        XCTAssertEqual(inputController.commandHistory(), ["look"])
        XCTAssertEqual(inputController.cmdBuf.count, 2)
        XCTAssertEqual(inputController.cmdIndex, 2)
    }
}

class SessionLogoffTests: XCTestCase {
    func testLogoffLinesToSendSplitsMultipleLines() {
        let world = World()
        world.logoffCmd = "quit\n@quit\n"
        let session = Session(world: world, sessionHandler: MockSessionHandler())

        XCTAssertEqual(session.logoffLinesToSend(), ["quit", "@quit"])
    }

    func testLogoffLinesToSendEmptyWhenUnset() {
        let world = World()
        let session = Session(world: world, sessionHandler: MockSessionHandler())

        XCTAssertEqual(session.logoffLinesToSend(), [])
    }
}

class OutputViewCaptureTests: XCTestCase {
    func testCaptureWritesPlainTextFromSessionOutput() throws {
        let outputView = OutputView(frame: .zero, configuration: WKWebViewConfiguration())
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Savitar2CaptureTest-\(UUID().uuidString).txt")

        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }

        XCTAssertTrue(outputView.startCapture(at: tempURL.path))
        XCTAssertTrue(outputView.isCapturing)

        outputView.output(string: "Room desc\r\nYou see a \u{001B}[32mdragon\u{001B}[0m.\n")

        XCTAssertTrue(outputView.stopCapture() == tempURL.path)
        XCTAssertFalse(outputView.isCapturing)

        let captured = try String(contentsOf: tempURL, encoding: .utf8)
        XCTAssertTrue(captured.contains("Room desc"))
        XCTAssertTrue(captured.contains("You see a dragon."))
        XCTAssertFalse(captured.contains("\u{001B}"))
    }

    func testCaptureSkipsStatusMessages() throws {
        let outputView = OutputView(frame: .zero, configuration: WKWebViewConfiguration())
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Savitar2CaptureSkipTest-\(UUID().uuidString).txt")

        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }

        XCTAssertTrue(outputView.startCapture(at: tempURL.path))
        outputView.output(string: "[SAVITAR] Capture started.\nSaving to /tmp/foo.txt\n",
                          skipCapture: true)
        outputView.output(string: "Server response:\nfoobar\n")
        _ = outputView.stopCapture()

        let captured = try String(contentsOf: tempURL, encoding: .utf8)
        XCTAssertFalse(captured.contains("Capture started"))
        XCTAssertFalse(captured.contains("Saving to"))
        XCTAssertTrue(captured.contains("Server response:"))
        XCTAssertTrue(captured.contains("foobar"))
    }

    func testCaptureIncludesHTMLFragmentPlainText() throws {
        let outputView = OutputView(frame: .zero, configuration: WKWebViewConfiguration())
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Savitar2CaptureHTMLTest-\(UUID().uuidString).txt")

        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }

        XCTAssertTrue(outputView.startCapture(at: tempURL.path))
        outputView.outputHTMLFragment("<strong>Welcome</strong> to Savitar")
        _ = outputView.stopCapture()

        let captured = try String(contentsOf: tempURL, encoding: .utf8)
        XCTAssertTrue(captured.contains("Welcome"))
        XCTAssertTrue(captured.contains("Savitar"))
    }
}

class OutputViewScrollLockTests: XCTestCase {
    func testScrollLockSuppressesAutoScrollJavaScript() {
        let outputView = OutputView(frame: .zero, configuration: WKWebViewConfiguration())

        XCTAssertFalse(outputView.isScrollLocked)
        XCTAssertTrue(outputView.scrollToBottomJavaScript().contains("scrollTo"))

        XCTAssertTrue(outputView.toggleScrollLock())
        XCTAssertTrue(outputView.isScrollLocked)
        XCTAssertEqual(outputView.scrollToBottomJavaScript(), "")

        outputView.setScrollLocked(false)
        XCTAssertFalse(outputView.isScrollLocked)
        XCTAssertTrue(outputView.scrollToBottomJavaScript().contains("scrollTo"))
    }
}
