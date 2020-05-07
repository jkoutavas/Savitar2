//
//  SelectionReducer.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/18/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import ReSwift

func selectionReducer(_ action: Action, state: SelectionState) -> SelectionState {
    guard let action = action as? SelectionAction else { return state }

    switch action {
    case .deselect: return nil
    case let .select(row: row): return row
    }
}
