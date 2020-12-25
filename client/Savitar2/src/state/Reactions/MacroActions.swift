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

enum MacroAction: ReactionUndoableAction {
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

    func inverse(context: ReactionsUndoContext) -> ReactionUndoableAction? {

        switch self {
        case let .changeKey(macroID, key: _):
            guard let prev = context.macroKey(macroID: macroID) else { return nil }
            return MacroAction.changeKey(macroID, key: prev)

        case let .changeValue(macroID, value: _):
            guard let prev = context.macroValue(macroID: macroID) else { return nil }
            return MacroAction.changeValue(macroID, value: prev)

        case let .disable(macroID):
            return MacroAction.enable(macroID)

        case let .enable(macroID):
            return MacroAction.disable(macroID)

        case let .rename(macroID, name: _):
            guard let prev = context.macroName(macroID: macroID) else { return nil }
            return MacroAction.rename(macroID, name: prev)
        }
    }
}
