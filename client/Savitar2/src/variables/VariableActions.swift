//
//  VariableActions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/17/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

protocol VariableSelectionAction: ApplicableAction {
}

struct SelectVariableAction: VariableSelectionAction {
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

protocol VariablesAction: ApplicableAction {
}

struct SetVariablesAction: VariablesAction {
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


