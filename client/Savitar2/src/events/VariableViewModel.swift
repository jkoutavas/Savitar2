//
//  VariableViewModel.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/8/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation

protocol DisplaysVariable {
    func showVariable(variableViewModel viewModel: VariableViewModel)
}

class VariableViewModel: CheckableItemViewModel {
    let hotKey: String
    let value: String

    init(variable: Variable) {
        hotKey = "hotKey" // TODO
        value = "value" // TODO
        super.init(identifier: variable.objectID.identifier,
                   title: variable.name,
                   enabled: variable.enabled)

    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
