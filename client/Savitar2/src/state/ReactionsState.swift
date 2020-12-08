//
//  ReactionsState.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/2/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

typealias SelectionState = Int?

protocol ReactionAction: Action {
    func apply(oldState: ReactionsState) -> ReactionsState
}

struct InsertMacroAction: UndoableAction, ReactionAction {
    let macro: Macro
    let index: Int

    init(macro: Macro, atIndex: Int) {
        self.macro = macro
        self.index = atIndex
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.macroList.insertItem(macro, atIndex: index)
        return result
    }

    var name: String { return "New Macro" }
    var isUndoable: Bool { return true }

    func inverse(context _: UndoActionContext) -> UndoableAction? {
        return RemoveMacroAction(macroID: macro.objectID)
    }
}

struct InsertTriggerAction: UndoableAction, ReactionAction {
    let trigger: Trigger
    let index: Int

    init(trigger: Trigger, atIndex: Int) {
        self.trigger = trigger
        self.index = atIndex
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.triggerList.insertItem(trigger, atIndex: index)
        return result
    }

    var name: String { return "New Trigger" }
    var isUndoable: Bool { return true }

    func inverse(context _: UndoActionContext) -> UndoableAction? {
        return RemoveTriggerAction(triggerID: trigger.objectID)
    }
}

struct MoveMacroAction: UndoableAction, ReactionAction {
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

    var name: String { return "Move Macro" }
    var isUndoable: Bool { return true }

    func inverse(context _: UndoActionContext) -> UndoableAction? {
        let movedDown = to > from
        let inversedFrom = movedDown ? to - 1 : to
        let inversedTo = movedDown ? from : from + 1

        return MoveMacroAction(from: inversedFrom, to: inversedTo)
    }
}

struct MoveTriggerAction: UndoableAction, ReactionAction {
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

    var name: String { return "Move Trigger" }
    var isUndoable: Bool { return true }

    func inverse(context _: UndoActionContext) -> UndoableAction? {
        let movedDown = to > from
        let inversedFrom = movedDown ? to - 1 : to
        let inversedTo = movedDown ? from : from + 1

        return MoveTriggerAction(from: inversedFrom, to: inversedTo)
    }
}

struct RemoveMacroAction: UndoableAction, ReactionAction {
    let macroID: SavitarObjectID

    init(macroID: SavitarObjectID) {
        self.macroID = macroID
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.macroList.removeItem(itemID: macroID)
        return result
    }

    var name: String { return "Delete Macro" }
    var isUndoable: Bool { return true }

    func inverse(context: UndoActionContext) -> UndoableAction? {
        guard let mlc = context.macroListContext(macroID: macroID) else { return nil }
        return InsertMacroAction(macro: mlc.macro, atIndex: mlc.index)
    }
}

struct RemoveTriggerAction: UndoableAction, ReactionAction {
    let triggerID: SavitarObjectID

    init(triggerID: SavitarObjectID) {
        self.triggerID = triggerID
    }

    func apply(oldState: ReactionsState) -> ReactionsState {
        var result = oldState
        result.triggerList.removeItem(itemID: triggerID)
        return result
    }

    var name: String { return "Delete Trigger" }
    var isUndoable: Bool { return true }

    func inverse(context: UndoActionContext) -> UndoableAction? {
        guard let tlc = context.triggerListContext(triggerID: triggerID) else { return nil }
        return InsertTriggerAction(trigger: tlc.trigger, atIndex: tlc.index)
    }
}

struct ItemListState<T: Equatable>: StateType {
    var items: [T] = []
    var selection: SelectionState = nil

    mutating func moveItems(from: Int, to: Int) {
        items.move(from: from, to: to)
    }

    func indexOf(objectID: SavitarObjectID) -> Int? {
        // swiftlint:disable force_cast
        return items.firstIndex(where: { ($0 as! SavitarObject).objectID == objectID })
        // swiftlint:enable force_cast
    }

    /// Always inserts `item` into the list:
    ///
    /// - if `index` exceeds the bounds of the collection it will be appended or prepended;
    /// - if `index` falls inside these bounds, it will be inserted between existing elements.
    mutating func insertItem(_ item: T, atIndex index: Int) {
        if index < 1 {
            items.insert(item, at: 0)
        } else if index < items.count {
            items.insert(item, at: index)
        } else {
            items.append(item)
        }
    }

    func item(objectID: SavitarObjectID) -> T? {
        guard let index = indexOf(objectID: objectID)
            else { return nil }

        return items[index]
    }

    mutating func removeItem(itemID: SavitarObjectID) {
        guard let index = indexOf(objectID: itemID) else { return }
        items.remove(at: index)
    }
}

struct ReactionsState: StateType {
    var macroList: ItemListState<Macro> = ItemListState<Macro>()
    var triggerList: ItemListState<Trigger> = ItemListState<Trigger>()
}

func reactionsReducer(action: Action, state: ReactionsState?) -> ReactionsState {
    guard var state = state else {
        return ReactionsState()
    }

    if let reactionAction = action as? ReactionAction {
        return reactionAction.apply(oldState: state)
    } else {
        if action is MacroAction {
            var macroList = state.macroList
            macroList.items = macroList.items.compactMap { macroReducer(action, state: $0) }
            state.macroList = macroList
        } else if action is TriggerAction {
            var triggerList = state.triggerList
            triggerList.items = triggerList.items.compactMap { triggerReducer(action, state: $0) }
            state.triggerList = triggerList
        }

        return state
    }
}

struct UndoManagerProvider {
    var undoManager: UndoManager?
}

typealias ReactionsStore = Store<ReactionsState>

// A typealias will not work and only raise EXC_BAD_ACCESS exceptions. ¯\_(ツ)_/¯
protocol UndoableAction: Action, Undoable { }

protocol ReactionStoreSetter {
    func setStore(reactionsStore: ReactionsStore?)
}

func reactionsStore(undoManagerProvider: @escaping () -> UndoManager?) -> ReactionsStore {
    return ReactionsStore(
        reducer: reactionsReducer,
        state: nil,
        middleware: [
            //            removeIdempotentActionsMiddleware,
            //            loggingMiddleware,
            undoMiddleware(undoManagerProvider: undoManagerProvider)
        ]
    )
}
