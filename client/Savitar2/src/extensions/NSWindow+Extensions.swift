//
//  NSWindow+Extensions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 3/3/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

extension NSWindow {
    var titlebarHeight: CGFloat {
        let contentHeight = contentRect(forFrameRect: frame).height
        return frame.height - contentHeight
    }
}
