//
//  WorldsUndoContext.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/19/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

protocol WorldsUndoContext {
    func worldListContext(worldID: SavitarObjectID) -> WorldListContext?
    func worldName(worldID: SavitarObjectID) -> String?
}

typealias WorldListContext = (world: World, index: Int)
