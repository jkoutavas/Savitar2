//
//  TrigTextStyle.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/7/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Cocoa

// https://en.wikipedia.org/wiki/ANSI_escape_code

extension NSColor {
    // This is kind of specific to what we need for generating ANSI color sequences,
    // thus it's not part of our generic `NSColor+Extensions` class. (We're ignoring
    // the alpha component, for example)
    func toIntArray() -> [Int] {
        var result: [Int] = []
        guard let components = cgColor.components else {
            return result
        }
        if components.count >= 3 {
            result.append(Int(components[0]*255.0))
            result.append(Int(components[1]*255.0))
            result.append(Int(components[2]*255.0))
        } else {
            // colors such as black and white have two components (color and alpha)
            result.append(Int(components[0]*255.0))
            result.append(Int(components[0]*255.0))
            result.append(Int(components[0]*255.0))
        }

        return result
    }

    func formOnFGColorANSICode() -> String {
        let rgb = self.toIntArray()
        return rgb.count >= 3 ? ";38:2;\(rgb[0]);\(rgb[1]);\(rgb[2])" : ""
    }

    func formOffFGColorANSICode() -> String {
        return ";39" // default foreground color
    }

    func formOnBGColorANSICode() -> String {
        let rgb = self.toIntArray()
        return rgb.count >= 3 ? ";48:2;\(rgb[0]);\(rgb[1]);\(rgb[2])" : ""
     }

    func formOffBGColorANSICode() -> String {
        return ";49" // default background color
    }
}

struct TrigFace: OptionSet, Hashable {
    let rawValue: Int

    static let normal = TrigFace(rawValue: 1 << 0)
    static let bold = TrigFace(rawValue: 1 << 1)
    static let italic = TrigFace(rawValue: 1 << 2)
    static let underline = TrigFace(rawValue: 1 << 3)
    static let blink = TrigFace(rawValue: 1 << 4) // new with version 2.0
    static let inverse = TrigFace(rawValue: 1 << 5) // new with version 2.0

    private func formANSICodes(dict: [TrigFace: Int]) -> String {
        var result = ""
        for (key, value) in dict.sorted(by: { $0.1 < $1.1 }) {
            if self.contains(key) {
                result += ";\(value)"
            }
        }

        return result
    }

    public func formOnANSICode() -> String {
        let styleOnDict: [TrigFace: Int] = [
            .blink: 5,
            .bold: 1,
            .inverse: 7,
            .italic: 3,
            .underline: 4
        ]
        return formANSICodes(dict: styleOnDict)
    }

    public func formOffANSICode() -> String {
        let styleOffDict: [TrigFace: Int] = [
            .blink: 25,
            .bold: 21,
            .inverse: 27,
            .italic: 23,
            .underline: 23
        ]
        return formANSICodes(dict: styleOffDict)
    }
}

struct TrigTextStyle: Equatable {
    // optional settings (at least one is set though to be effective)
    var face: TrigFace?
    var foreColor: NSColor?
    var backColor: NSColor? // new with version 2.0

    public var on: String = ""
    public var off: String = ""

    private func formEscapeSequence(codes: String) -> String {
        let esc = "\u{1B}"
        return codes.count > 0 ? esc + "[" + codes + "m" : ""
    }

    init(face: TrigFace? = nil,
         foreColor: NSColor? = nil,
         backColor: NSColor? = nil) {

        self.face = face
        self.foreColor = foreColor
        self.backColor = backColor

        /*
         * For perfomance reasons, formulate the on and off escape sequences as they are set
         */
        let faceOn = face?.formOnANSICode() ?? ""
        let faceOff = face?.formOffANSICode() ?? ""

        let fgColorOn = foreColor?.formOnFGColorANSICode() ?? ""
        let fgColorOff = foreColor?.formOffFGColorANSICode() ?? ""

        let bgColorOn = backColor?.formOnBGColorANSICode() ?? ""
        let bgColorOff = backColor?.formOffBGColorANSICode() ?? ""

        self.on = formEscapeSequence(codes: faceOn + fgColorOn + bgColorOn)
        self.off = formEscapeSequence(codes: faceOff + fgColorOff + bgColorOff)
    }
}