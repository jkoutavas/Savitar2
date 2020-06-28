//
//  MacrosViewModel.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/8/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation

struct MacrosViewModel {
    let macros: [MacroViewModel]
    var itemCount: Int { return macros.count }

    let selectedRow: Int?
    var selectedMacro: MacroViewModel? {
        guard let selectedRow = selectedRow else { return nil }
        return macros[selectedRow]
    }
}
