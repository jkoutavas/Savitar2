//
//  String+Extensions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/25/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Foundation

extension String {
    func dropPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
