//
//  WorldsViewModel.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/13/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation

struct WorldsViewModel {
    let worlds: [WorldViewModel]
    var itemCount: Int { return worlds.count }

    let selectedRow: Int?
    var selectedWorld: WorldViewModel? {
        guard let selectedRow = selectedRow else { return nil }
        return worlds[selectedRow]
    }
}
