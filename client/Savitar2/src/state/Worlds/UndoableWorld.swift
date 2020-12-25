//
//  UndoableWorld.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/19/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation

protocol UndoableWorld {
    /// Name used for e.g. "Undo" menu items.
    var name: String { get }

    var notUndoable: NotUndoable { get }
    var isUndoable: Bool { get }

    func inverse(context: WorldsUndoContext) -> WorldUndoableAction?
}

extension UndoableWorld where Self: WorldUndoableAction {
    var notUndoable: NotUndoable {
        return NotUndoable(self)
    }
}
