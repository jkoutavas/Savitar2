//
//  Array+Extansions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/5/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}
