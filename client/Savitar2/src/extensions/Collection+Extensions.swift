//
//  Collection+Extensions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/3/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//
//  Borrowed from:
//
//  CollectionType+ReSwiftTodo.swift
//  ReSwift-Todo
//
//  Created by Christian Tietze on 06/09/16.
//  Copyright © 2016 ReSwift. All rights reserved.

import Foundation

extension Collection where Self.Index: Comparable {
    subscript(safe index: Self.Index) -> Self.Iterator.Element? {
        return index < endIndex ? self[index] : nil
    }
}
