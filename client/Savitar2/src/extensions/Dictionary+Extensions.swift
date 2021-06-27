//
//  Dictionary+Extensions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/28/21.
//  Copyright © 2021 Heynow Software. All rights reserved.
//

import Foundation

extension Dictionary where Value: Equatable {
    func key(from value: Value) -> Key? {
        return self.first(where: { $0.value == value })?.key
    }
}
