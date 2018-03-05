//
//  CGFloat+Extensions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 3/3/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Foundation

extension CGFloat {
    init?(_ str: String) {
        guard let float = Float(str) else { return nil }
        self = CGFloat(float)
    }
}
