//
//  TrigTextStyle.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/7/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation

struct TrigFace: OptionSet, Hashable {
    let rawValue: Int

    static let normal = TrigFace(rawValue: 1 << 0)
    static let bold = TrigFace(rawValue: 1 << 1)
    static let italic = TrigFace(rawValue: 1 << 2)
    static let underline = TrigFace(rawValue: 1 << 3)
    static let blink = TrigFace(rawValue: 1 << 4) // new with version 2.0
}

struct TrigTextStyle: Equatable {
    let styleOnDict: [TrigFace: Int] = [
        .blink: 5,
        .bold: 1,
        .italic: 3,
        .underline: 4
    ]

    let styleOffDict: [TrigFace: Int] = [
        .blink: 25,
        .bold: 21,
        .italic: 23,
        .underline: 23
    ]

    public var on: String = ""
    public var off: String = ""

    let face: TrigFace?
    let foreColor: String?
    let backColor: String?

    private func buildEscapeCode(dict: [TrigFace: Int]) -> String {
        var result = ""
        if let face = self.face {
            for (key, value) in dict {
                if face.contains(key) {
                    result += ";\(value)"
                }
            }
            if result.count > 0 {
                let esc = "\u{1B}"
                result = esc + "[" + result + "m"
            }
        }
        return result
    }

    init(face: TrigFace? = nil,
         foreColor: String? = nil,
         backColor: String? = nil) {

        self.face = face
        self.foreColor = foreColor
        self.backColor = backColor

        self.on = buildEscapeCode(dict: styleOnDict)
        self.off = buildEscapeCode(dict: styleOffDict)
    }
}
