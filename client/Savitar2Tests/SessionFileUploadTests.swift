//
//  SessionFileUploadTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import XCTest

@testable import Savitar2

private final class UploadMockSessionHandler: SessionHandlerProtocol {
    var outputs: [String] = []
    var echoBackOutputs: [String] = []

    func connectionStatusChanged(status _: ConnectionStatus) {}
    func output(result: OutputResult, skipCapture _: Bool) {
        if case let .success(output) = result {
            outputs.append(output)
        }
    }
    func outputEchoBack(_ text: String, skipCapture _: Bool) {
        echoBackOutputs.append(text)
    }
    func printSource() {}
    func commandHistory() -> [String] { [] }
    func setSessionStatus(pane _: SessionStatusPane, text _: String) {}
    func closeSessionStatusBars() {}
}

class SessionFileUploadTests: XCTestCase {
    func testResolvePathExpandsTildeAndRelativePaths() {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        XCTAssertEqual(SessionFileUpload.resolvePath("~/Documents/foo.txt"),
                       "\(home)/Documents/foo.txt")
        XCTAssertEqual(SessionFileUpload.resolvePath("Documents/foo.txt"),
                       "\(home)/Documents/foo.txt")
        XCTAssertEqual(SessionFileUpload.resolvePath("/tmp/foo.txt"), "/tmp/foo.txt")
    }

    func testUploadSendsRawFileBytes() throws {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Savitar2UploadTest-\(UUID().uuidString).txt")
        let contents = "look\nsay hello\r\n"
        try contents.write(to: tempURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let session = Session(world: World(), sessionHandler: UploadMockSessionHandler())
        session.status = .ConnectComplete
        var sentData: Data?

        let result = SessionFileUpload.upload(path: tempURL.path, session: session) { data in
            sentData = data
        }

        XCTAssertEqual(result, .success(contents.utf8.count))
        XCTAssertEqual(sentData, contents.data(using: .utf8))
    }

    func testUploadRequiresActiveConnection() {
        let session = Session(world: World(), sessionHandler: UploadMockSessionHandler())
        session.status = .DisconnectComplete

        XCTAssertEqual(SessionFileUpload.upload(path: "/tmp/missing.txt", session: session) { _ in },
                       .failure(.notConnected))
    }

    func testUploadCommandReportsMissingFile() {
        let missingPath = "/tmp/does-not-exist-\(UUID().uuidString).txt"
        let handler = UploadMockSessionHandler()
        let session = Session(world: World(), sessionHandler: handler)
        session.status = .ConnectComplete

        session.submitServerCmd(cmd: Command(text: "##upload \(missingPath)"))

        XCTAssertEqual(handler.echoBackOutputs, [
            "[SAVITAR] File not found: \(missingPath)\n"
        ])
        XCTAssertTrue(handler.outputs.isEmpty)
    }
}
