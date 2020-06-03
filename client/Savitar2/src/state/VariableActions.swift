//
//  VariableActions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/17/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

struct SelectVariableAction: ReactionAction {
    let selection: SelectionState

    init(selection: SelectionState) {
        self.selection = selection
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.variableList.selection = selection
        return result
    }
}

struct SetVariablesAction: ReactionAction {
    let variables: [Variable]

    init(variables: [Variable]) {
        self.variables = variables
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.variableList.items = variables
        return result
    }
}

enum VariableAction: UndoableAction {
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
        case .enable(let variableID):
            return VariableAction.disable(variableID)
        case .disable(let variableID):
            return VariableAction.enable(variableID)
        }
    }
}
