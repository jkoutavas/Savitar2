//
//  WorldsActions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/19/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

// A typealias will not work and only raise EXC_BAD_ACCESS exceptions. ¯\_(ツ)_/¯
protocol WorldUndoableAction: Action, UndoableWorld {}

protocol WorldAction: Action {
    func apply(oldState: WorldsState) -> WorldsState
}

struct SetWorldsAction: WorldAction {
    let worlds: [World]

    init(worlds: [World]) {
        self.worlds = worlds
    }

    func apply(oldState: WorldsState) -> WorldsState {
        var result = oldState
        result.worldList.items = worlds
        return result
    }
}

struct SelectWorldAction: WorldAction {
    let selection: SelectionState

    init(selection: SelectionState) {
        self.selection = selection
    }

    func apply(oldState: WorldsState) -> WorldsState {
        var result = oldState
        result.worldList.selection = selection
        return result
    }
}

struct InsertWorldAction: WorldUndoableAction, WorldAction {
    let world: World
    let index: Int

    init(world: World, atIndex: Int) {
        self.world = world
        index = atIndex
    }

    func apply(oldState: WorldsState) -> WorldsState {
        var result = oldState
        result.worldList.insertItem(world, atIndex: index)
        return result
    }

    var name: String { return "New World" }
    var isUndoable: Bool { return true }

    func inverse(context _: WorldsUndoContext) -> WorldUndoableAction? {
        return RemoveWorldAction(worldID: world.objectID)
    }
}

struct RemoveWorldAction: WorldUndoableAction, WorldAction {
    let worldID: SavitarObjectID

    init(worldID: SavitarObjectID) {
        self.worldID = worldID
    }

    func apply(oldState: WorldsState) -> WorldsState {
        var result = oldState
        result.worldList.removeItem(itemID: worldID)
        return result
    }

    var name: String { return "Delete World" }
    var isUndoable: Bool { return true }

    func inverse(context: WorldsUndoContext) -> WorldUndoableAction? {
        guard let wlc = context.worldListContext(worldID: worldID) else { return nil }
        return InsertWorldAction(world: wlc.world, atIndex: wlc.index)
    }
}
