//
//  Data+Extensions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/30/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation

extension Data {
    mutating func append(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }

    var hexString: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
}
