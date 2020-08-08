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
    case changeKey(SavitarObjectID, key: HotKey)
    case changeValue(SavitarObjectID, value: String)
    case disable(SavitarObjectID)
    case enable(SavitarObjectID)
    case rename(SavitarObjectID, name: String)

    // MARK: Undoable

    var isUndoable: Bool { return true }

    var name: String {
        switch self {
        case .changeKey: return "Change Macro Key"
        case .changeValue: return "Change Macro Value"
        case .disable: return "Disable Macro"
        case .enable: return "Enable Macro"
        case .rename: return "Rename Macro"
        }
    }

    func inverse(context: UndoActionContext) -> UndoableAction? {

        switch self {
        case .changeKey(let macroID, key: _):
            guard let oldKey = context.macroKey(macroID: macroID) else { return nil }
            return MacroAction.changeKey(macroID, key: oldKey)

        case .changeValue(let macroID, value: _):
            guard let oldValue = context.macroValue(macroID: macroID) else { return nil }
            return MacroAction.changeValue(macroID, value: oldValue)

        case .disable(let macroID):
            return MacroAction.enable(macroID)

        case .enable(let macroID):
            return MacroAction.disable(macroID)

        case .rename(let macroID, name: _):
            guard let oldName = context.macroName(macroID: macroID) else { return nil }
            return MacroAction.rename(macroID, name: oldName)
        }
    }
}
