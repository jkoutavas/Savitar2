//
//  WorldController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/5/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class WorldController: NSController {
    var world: World

    @objc dynamic var editable = true

    // TODO: is there a more elegant way of representing this?
    @objc dynamic var name: String { get { world.name } set(name) { world.name = name } }
    @objc dynamic var port: UInt32 { get { world.port } set(port) { world.port = port } }
    @objc dynamic var host: String { get { world.host } set(host) { world.host = host } }
    @objc dynamic var cmdMarker: String { get { world.cmdMarker } set(cmdMarker) { world.cmdMarker = cmdMarker } }
    @objc dynamic var varMarker: String { get { world.varMarker } set(varMarker) { world.varMarker = varMarker } }
    @objc dynamic var wildMarker: String { get { world.wildMarker } set(wildMarker) { world.wildMarker = wildMarker } }
    @objc dynamic var backColor: NSColor { get { world.backColor } set(backColor) { world.backColor = backColor } }
    @objc dynamic var foreColor: NSColor { get { world.foreColor } set(foreColor) { world.foreColor = foreColor } }
    @objc dynamic var linkColor: NSColor { get { world.linkColor } set(linkColor) { world.linkColor = linkColor } }
    @objc dynamic var echoBackColor: NSColor { get { world.echoBackColor } set(echoBackColor) {
        world.echoBackColor = echoBackColor } }
    @objc dynamic var intenseColor: NSColor { get { world.intenseColor } set(intenseColor) {
        world.intenseColor = intenseColor } }
    @objc dynamic var fontName: String { get { world.fontName } set(fontName) { world.fontName = fontName } }
    @objc dynamic var fontSize: CGFloat { get { world.fontSize } set(fontSize) { world.fontSize = fontSize } }
    @objc dynamic var monoFontName: String { get { world.monoFontName } set(monoFontName) {
        world.monoFontName = monoFontName } }
    @objc dynamic var monoFontSize: CGFloat { get { world.monoFontSize } set(monoFontSize) {
        world.monoFontSize = monoFontSize } }
    @objc dynamic var MCPFontName: String { get { world.MCPFontName } set(MCPFontName) {
        world.MCPFontName = MCPFontName } }
    @objc dynamic var MCPFontSize: CGFloat { get { world.MCPFontSize } set(MCPFontSize) {
        world.MCPFontSize = MCPFontSize } }
    @objc dynamic var logonCmd: String { get { world.logonCmd } set(logonCmd) { world.logonCmd = logonCmd } }
    @objc dynamic var logoffCmd: String { get { world.logoffCmd } set(logoffCmd) { world.logoffCmd = logoffCmd } }

    @objc dynamic var ansiEnabled: Bool {
        get { world.flags.contains(.ansi) }
        set(enabled) {
            if enabled {
                world.flags.insert(.ansi)
            } else {
                world.flags.remove(.ansi)
            }
        }
    }

    @objc dynamic var htmlEnabled: Bool {
        get { world.flags.contains(.html) }
        set(enabled) {
            if enabled {
                world.flags.insert(.html)
            } else {
                world.flags.remove(.html)
            }
        }
    }

    init(world: World) {
        self.world = world

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
