//
//  NotUndoable.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/24/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

/// Wrapper around an action to flag it as not undoable, like when it's
/// already on the undo-stack.
struct NotUndoable: Action {
    let action: Action

    init(_ action: Action) {
        self.action = action
    }
}

extension NotUndoable: CustomStringConvertible {
    var description: String {
        return "NotUndoable for \(action)"
    }
}
