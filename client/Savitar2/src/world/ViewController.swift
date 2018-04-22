//
//  ViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 2017 Heynow Software. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var textView: NSTextView!

    public var backColor : NSColor {
        get {
            return textView.backgroundColor
        }
        set {
            textView.backgroundColor = newValue
        }
    }

    public var foreColor : NSColor {
        get {
            return textView.textColor!
        }
        set {
            textView.textColor = newValue
        }
    }

    public var font : NSFont {
        get {
            return textView.font!
        }
        set {
            textView.font = newValue
        }
    }

    public var rowHeight : CGFloat {
        get {
            return textView.layoutManager!.defaultLineHeight(for: font)
        }
    }
 }

