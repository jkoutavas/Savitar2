//
//  ReactionsActions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/19/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import ReSwift

protocol ReactionUndoableAction: Action, UndoableReaction {}

protocol ReactionAction: Action {
    func apply(oldState: ReactionsState) -> ReactionsState
}

struct InsertMacroAction: ReactionUndoableAction, ReactionAction {
    let macro: Macro
    let index: Int

    init(macro: Macro, atIndex: Int) {
        self.macro = macro
        index = atIndex
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.macroList.insertItem(macro, atIndex: index)
        return result
    }

    var name = "New Macro"

    func inverse(context _: ReactionsUndoContext) -> ReactionUndoableAction? {
        return RemoveMacroAction(macroID: macro.objectID)
    }
}

struct InsertTriggerAction: ReactionUndoableAction, ReactionAction {
    let trigger: Trigger
    let index: Int

    init(trigger: Trigger, atIndex: Int) {
        self.trigger = trigger
        index = atIndex
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.triggerList.insertItem(trigger, atIndex: index)
        return result
    }

    var name = "New Trigger"

    func inverse(context _: ReactionsUndoContext) -> ReactionUndoableAction? {
        return RemoveTriggerAction(triggerID: trigger.objectID)
    }
}

struct MoveMacroAction: ReactionUndoableAction, ReactionAction {
    let from: Int
    let to: Int

    init(from: Int, to: Int) {
        self.from = from
        self.to = to
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.macroList.moveItems(from: from, to: to)
        return result
    }

    var name = "Move Macro"

    func inverse(context _: ReactionsUndoContext) -> ReactionUndoableAction? {
        let movedDown = to > from
        let inversedFrom = movedDown ? to - 1 : to
        let inversedTo = movedDown ? from : from + 1

        return MoveMacroAction(from: inversedFrom, to: inversedTo)
    }
}

struct MoveTriggerAction: ReactionUndoableAction, ReactionAction {
    let from: Int
    let to: Int

    init(from: Int, to: Int) {
        self.from = from
        self.to = to
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.triggerList.moveItems(from: from, to: to)
        return result
    }

    var name = "Move Trigger"

    func inverse(context _: ReactionsUndoContext) -> ReactionUndoableAction? {
        let movedDown = to > from
        let inversedFrom = movedDown ? to - 1 : to
        let inversedTo = movedDown ? from : from + 1

        return MoveTriggerAction(from: inversedFrom, to: inversedTo)
    }
}

struct RemoveMacroAction: ReactionUndoableAction, ReactionAction {
    let macroID: SavitarObjectID

    init(macroID: SavitarObjectID) {
        self.macroID = macroID
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.macroList.removeItem(itemID: macroID)
        return result
    }

    var name = "Delete Macro"

    func inverse(context: ReactionsUndoContext) -> ReactionUndoableAction? {
        guard let mlc = context.macroListContext(macroID: macroID) else { return nil }
        return InsertMacroAction(macro: mlc.macro, atIndex: mlc.index)
    }
}

struct RemoveTriggerAction: ReactionUndoableAction, ReactionAction {
    let triggerID: SavitarObjectID

    init(triggerID: SavitarObjectID) {
        self.triggerID = triggerID
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.triggerList.removeItem(itemID: triggerID)
        return result
    }

    var name = "Delete Trigger"

    func inverse(context: ReactionsUndoContext) -> ReactionUndoableAction? {
        guard let tlc = context.triggerListContext(triggerID: triggerID) else { return nil }
        return InsertTriggerAction(trigger: tlc.trigger, atIndex: tlc.index)
    }
}
