//
//  TelnetURLHandlerTests.swift
//  Savitar2Tests
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

@testable import Savitar2
import XCTest

final class TelnetURLHandlerTests: XCTestCase {
    func testParseHostAndPort() throws {
        let url = try XCTUnwrap(URL(string: "telnet://dentinmud.org:3000"))
        let parsed = try XCTUnwrap(TelnetURLHandler.parse(url))
        XCTAssertEqual(parsed.host, "dentinmud.org")
        XCTAssertEqual(parsed.port, 3000)
    }

    func testParseDefaultsPortTo23() throws {
        let url = try XCTUnwrap(URL(string: "telnet://example.com"))
        let parsed = try XCTUnwrap(TelnetURLHandler.parse(url))
        XCTAssertEqual(parsed.host, "example.com")
        XCTAssertEqual(parsed.port, TelnetURLHandler.defaultPort)
    }

    func testParseIPv6HostAndPort() throws {
        let url = try XCTUnwrap(URL(string: "telnet://[::1]:4000"))
        let parsed = try XCTUnwrap(TelnetURLHandler.parse(url))
        XCTAssertEqual(parsed.host, "::1")
        XCTAssertEqual(parsed.port, 4000)
    }

    func testParseRejectsNonTelnetScheme() throws {
        let url = try XCTUnwrap(URL(string: "https://example.com:443"))
        XCTAssertNil(TelnetURLHandler.parse(url))
    }

    func testParseIsCaseInsensitiveOnScheme() throws {
        let url = try XCTUnwrap(URL(string: "TELNET://mud.example.com:7777"))
        let parsed = try XCTUnwrap(TelnetURLHandler.parse(url))
        XCTAssertEqual(parsed.host, "mud.example.com")
        XCTAssertEqual(parsed.port, 7777)
    }

    func testWorldMatchingIsCaseInsensitiveOnHost() {
        let world = World()
        world.name = "Alter Aeon"
        world.host = "DentinMud.org"
        world.port = 3000

        let other = World()
        other.name = "Other"
        other.host = "example.com"
        other.port = 4000

        let matched = TelnetURLHandler.matchingWorld(host: "dentinmud.org",
                                                     port: 3000,
                                                     in: [other, world])
        XCTAssertTrue(matched === world)

        XCTAssertNil(TelnetURLHandler.matchingWorld(host: "dentinmud.org",
                                                    port: 4000,
                                                    in: [world, other]))
    }

    func testEphemeralWorldUsesHostAsName() {
        let world = TelnetURLHandler.ephemeralWorld(host: "mud.example.com", port: 4242)
        XCTAssertEqual(world.name, "mud.example.com")
        XCTAssertEqual(world.host, "mud.example.com")
        XCTAssertEqual(world.port, 4242)
        XCTAssertEqual(world.telnetString, "telnet://mud.example.com:4242")
    }
}
