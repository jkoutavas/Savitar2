//
//  MacroActions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/17/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

struct SelectMacroAction: ReactionAction {
    let selection: SelectionState

    init(selection: SelectionState) {
        self.selection = selection
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.macroList.selection = selection
        return result
    }
}

struct SetMacrosAction: ReactionAction {
    let macros: [Macro]

    init(macros: [Macro]) {
        self.macros = macros
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.macroList.items = macros
        return result
    }
}

enum MacroAction: UndoableAction {
    case enable(SavitarObjectID)
    case disable(SavitarObjectID)

    // MARK: Undoable

    var isUndoable: Bool { return true }

    var name: String {
        switch self {
        case .enable: return "Enable Macro"
        case .disable: return "Disable Macro"
        }
    }

    func inverse(context: UndoActionContext) -> UndoableAction? {

        switch self {
        case .enable(let macroID):
            return MacroAction.disable(macroID)
        case .disable(let macroID):
            return MacroAction.enable(macroID)
        }
    }
}
