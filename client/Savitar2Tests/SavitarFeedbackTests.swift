//
//  SavitarFeedbackTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

@testable import Savitar2
import XCTest

final class SavitarFeedbackTests: XCTestCase {
    func testSupportEmailIsNonEmpty() {
        XCTAssertFalse(SavitarFeedback.supportEmail.isEmpty)
        XCTAssertTrue(SavitarFeedback.supportEmail.contains("@"))
    }

    func testDiagnosticsTextIncludesVersionFields() {
        let text = SavitarFeedback.diagnosticsText()
        XCTAssertTrue(text.contains("Savitar version:"))
        XCTAssertTrue(text.contains("Build:"))
        XCTAssertTrue(text.contains("macOS:"))
        XCTAssertTrue(text.contains(SavitarFeedback.supportEmail))
    }

    func testFeedbackEmailBodyIncludesPromptSections() {
        let body = SavitarFeedback.feedbackEmailBodyTemplate()
        XCTAssertTrue(body.contains("What I was trying to do:"))
        XCTAssertTrue(body.contains("What happened:"))
        XCTAssertTrue(body.contains("Bug or feature request?"))
        XCTAssertTrue(body.contains("Diagnostics"))
    }

    func testMakeMailtoURLUsesSupportEmailAndSubject() throws {
        let url = try XCTUnwrap(SavitarFeedback.makeMailtoURL())
        XCTAssertEqual(url.scheme, "mailto")
        XCTAssertTrue(url.absoluteString.contains(SavitarFeedback.supportEmail))
        XCTAssertTrue(url.absoluteString.lowercased().contains("subject="))
        XCTAssertTrue(url.absoluteString.lowercased().contains("body="))
    }
}
