//
//  MacroViewModel.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/8/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation

protocol DisplaysMacro {
    func showMacro(macroViewModel viewModel: MacroViewModel)
}

class MacroViewModel: CheckableItemViewModel {
    let hotKey: String
    let value: String

    init(macro: Macro) {
        hotKey = macro.keyLabel
        value = macro.value
        super.init(itemID: macro.objectID.identifier,
                   title: macro.name,
                   enabled: macro.enabled)
    }

    required init(from _: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
