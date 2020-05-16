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

struct VariableViewModel: Codable {
    let identifier: String

    let enabled: Bool
    let name: String
    let hotKey: String
    let value: String

    init(variable: Variable) {
        identifier = variable.objectID.identifier

        enabled = variable.enabled
        name = variable.name
        hotKey = "hotKey" // TODO
        value = "value" // TODO
    }
}
