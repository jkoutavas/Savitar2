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
    
    public func setFont(name:String, size:CGFloat) {
        textView.font = NSFont(name: name, size: size)
    }
 }

