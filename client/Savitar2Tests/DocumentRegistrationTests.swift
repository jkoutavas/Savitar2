//
//  DocumentRegistrationTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

@testable import Savitar2
import XCTest

final class DocumentRegistrationTests: XCTestCase {
    func testRegisterWithDocumentControllerIfNeeded() {
        let document = DocumentV2()
        document.registerWithDocumentControllerIfNeeded()
        XCTAssertTrue(NSDocumentController.shared.documents.contains(where: { $0 === document }))
        NSDocumentController.shared.removeDocument(document)
    }

    func testRegisterWithDocumentControllerIfNeededIsIdempotent() {
        let document = DocumentV2()
        document.registerWithDocumentControllerIfNeeded()
        document.registerWithDocumentControllerIfNeeded()
        let matches = NSDocumentController.shared.documents.filter { $0 === document }
        XCTAssertEqual(matches.count, 1)
        NSDocumentController.shared.removeDocument(document)
    }
}
