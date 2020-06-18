//
//  VariableReducer.swift
//  Savitar2
//
//  Created by Jay Koutavas on 6/2/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import ReSwift

func variableReducer(_ action: Action, state: Variable?) -> Variable? {

    guard let action = action as? VariableAction,
        let variable = state
        else { return state }

    return handleVariableAction(action, variable: variable)
}

private func handleVariableAction(_ action: VariableAction, variable: Variable) -> Variable {

    let variable = variable

    switch action {
    case let .enable(variableID):
        guard variable.objectID == variableID else { return variable }
        variable.enabled = true

    case let .disable(variableID):
        guard variable.objectID == variableID else { return variable }
        variable.enabled = false
    }

    return variable
}
