//
//  ListViewModel.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/24/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation

struct ListViewModel<T> {
    let viewModels: [T]
    var itemCount: Int { return viewModels.count }

    let selectedRow: Int?
    var selectedItem: T? {
        guard let selectedRow = selectedRow else { return nil }
        return viewModels[selectedRow]
    }
}
