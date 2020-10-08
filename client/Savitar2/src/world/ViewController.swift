//
//  ViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 2017 Heynow Software. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var textView: NSTextView!

    public var backColor: NSColor {
        get {
            return textView.backgroundColor
        }
        set {
            textView.backgroundColor = newValue
        }
    }

    public var foreColor: NSColor {
        get {
            return textView.textColor ?? NSColor.white
        }
        set {
            textView.textColor = newValue
        }
    }

    public var font: NSFont {
        get {
            return textView.font ?? NSFont.systemFont(ofSize: 9)
        }
        set {
            textView.font = newValue
        }
    }

    func rowHeight() -> CGFloat {
        return textView.layoutManager?.defaultLineHeight(for: font) ?? 0
    }
}
