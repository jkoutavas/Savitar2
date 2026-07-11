//
//  EventsWindowControllerTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

@testable import Savitar2
import XCTest

final class EventsWindowControllerTests: XCTestCase {
    func testDesignedContentSizeMatchesStoryboardLayout() {
        XCTAssertEqual(EventsWindowController.designedContentSize, NSSize(width: 900, height: 400))
    }

    func testHasAutosavedFrameWhenMissing() {
        let name = "Savitar2TestEventsWindowFrameMissing"
        UserDefaults.standard.removeObject(forKey: "NSWindow Frame \(name)")
        XCTAssertFalse(NSWindow.hasAutosavedFrame(named: name))
    }

    func testHasAutosavedFrameWhenPresent() {
        let name = "Savitar2TestEventsWindowFramePresent"
        UserDefaults.standard.set("100 200 900 400 0 0 1920 1177 ", forKey: "NSWindow Frame \(name)")
        defer { UserDefaults.standard.removeObject(forKey: "NSWindow Frame \(name)") }
        XCTAssertTrue(NSWindow.hasAutosavedFrame(named: name))
    }

    func testWindowChromeIsCloseOnly() {
        let bundle = Bundle(for: EventsWindowController.self)
        let storyboard = NSStoryboard(name: "EventsWindow", bundle: bundle)
        guard let controller = storyboard.instantiateInitialController() as? EventsWindowController else {
            XCTFail("Expected EventsWindowController")
            return
        }
        controller.loadWindow()
        guard let window = controller.window else {
            XCTFail("Expected window")
            return
        }
        XCTAssertEqual(window.styleMask, [.titled, .closable])
        XCTAssertEqual(window.contentMinSize, EventsWindowController.designedContentSize)
        XCTAssertEqual(window.contentMaxSize, EventsWindowController.designedContentSize)
    }
}
