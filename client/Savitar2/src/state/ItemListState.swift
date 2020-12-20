//
//  ItemListState.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/19/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

typealias SelectionState = Int?

struct ItemListState<T: Equatable>: StateType {
    var items: [T] = []
    var selection: SelectionState = nil

    mutating func moveItems(from: Int, to: Int) {
        items.move(from: from, to: to)
    }

    func indexOf(objectID: SavitarObjectID) -> Int? {
        // swiftlint:disable force_cast
        return items.firstIndex(where: { ($0 as! SavitarObject).objectID == objectID })
        // swiftlint:enable force_cast
    }

    /// Always inserts `item` into the list:
    ///
    /// - if `index` exceeds the bounds of the collection it will be appended or prepended;
    /// - if `index` falls inside these bounds, it will be inserted between existing elements.
    mutating func insertItem(_ item: T, atIndex index: Int) {
        if index < 1 {
            items.insert(item, at: 0)
        } else if index < items.count {
            items.insert(item, at: index)
        } else {
            items.append(item)
        }
    }

    func item(objectID: SavitarObjectID) -> T? {
        guard let index = indexOf(objectID: objectID)
            else { return nil }

        return items[index]
    }

    mutating func removeItem(itemID: SavitarObjectID) {
        guard let index = indexOf(objectID: itemID) else { return }
        items.remove(at: index)
    }
}
