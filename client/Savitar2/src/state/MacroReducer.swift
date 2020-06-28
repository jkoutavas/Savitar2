//
//  MacroReducer.swift
//  Savitar2
//
//  Created by Jay Koutavas on 6/2/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import ReSwift

func macroReducer(_ action: Action, state: Macro?) -> Macro? {

    guard let action = action as? MacroAction,
        let macro = state
        else { return state }

    return handleMacroAction(action, macro: macro)
}

private func handleMacroAction(_ action: MacroAction, macro: Macro) -> Macro {

    let macro = macro

    switch action {
    case let .enable(macroID):
        guard macro.objectID == macroID else { return macro }
        macro.enabled = true

    case let .disable(macroID):
        guard macro.objectID == macroID else { return macro }
        macro.enabled = false
    }

    return macro
}
