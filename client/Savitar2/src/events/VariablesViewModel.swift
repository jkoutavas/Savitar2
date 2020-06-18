//
//  VariablesViewModel.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/8/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation

struct VariablesViewModel {
    let variables: [VariableViewModel]
    var itemCount: Int { return variables.count }

    let selectedRow: Int?
    var selectedVariable: VariableViewModel? {
        guard let selectedRow = selectedRow else { return nil }
        return variables[selectedRow]
    }
}
