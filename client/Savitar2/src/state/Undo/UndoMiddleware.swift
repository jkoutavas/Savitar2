//
//  UndoMiddleware.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/29/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

class UndoableStateAdapter: UndoActionContext {
    let state: ReactionsState

    init(reactionsState: ReactionsState) {
        state = reactionsState
    }

    func macroName(macroID: SavitarObjectID) -> String? {
        return state.macroList.item(objectID: macroID)?.name
    }

    func macroKey(macroID: SavitarObjectID) -> HotKey? {
        return state.macroList.item(objectID: macroID)?.hotKey
    }

    func macroValue(macroID: SavitarObjectID) -> String? {
        return state.macroList.item(objectID: macroID)?.value
    }

    func triggerMatching(triggerID: SavitarObjectID) -> TriggerMatching? {
        return state.triggerList.item(objectID: triggerID)?.matching
    }

    func triggerName(triggerID: SavitarObjectID) -> String? {
        return state.triggerList.item(objectID: triggerID)?.name
    }

    func triggerSubstitution(triggerID: SavitarObjectID) -> String? {
        return state.triggerList.item(objectID: triggerID)?.substitution
    }

    func triggerType(triggerID: SavitarObjectID) -> TrigType? {
        return state.triggerList.item(objectID: triggerID)?.type
    }

    func triggerWordEnding(triggerID: SavitarObjectID) -> String? {
        return state.triggerList.item(objectID: triggerID)?.wordEnding
    }
}

extension UndoCommand {
    convenience init?(appAction: UndoableAction, context: UndoActionContext, dispatch: @escaping DispatchFunction) {
        guard let inverseAction = appAction.inverse(context: context)
            else { return nil }

        self.init(undoBlock: { _ = dispatch(inverseAction.notUndoable) },
                  undoName: appAction.name,
                  redoBlock: { _ = dispatch(appAction.notUndoable) })
    }
}

func undoMiddleware(undoManagerProvider: @escaping () -> UndoManager?) -> Middleware<ReactionsState> {
    func undoAction(action: UndoableAction, state: ReactionsState, dispatch: @escaping DispatchFunction) -> UndoCommand? {
        let context = UndoableStateAdapter(reactionsState: state)

        return UndoCommand(appAction: action, context: context, dispatch: dispatch)
    }
    let undoMiddleware: Middleware<ReactionsState> = { dispatch, getState in {
        next in {
            action in

            // Pass already undone actions through
            if let undoneAction = action as? NotUndoable {
                next(undoneAction.action)
                return
            }

            if let undoableAction = action as? UndoableAction, undoableAction.isUndoable,
                let state = getState(),
                let undo = undoAction(action: undoableAction, state: state, dispatch: dispatch),
                let undoManager = undoManagerProvider() {
                undo.register(undoManager: undoManager)
            }

            next(action)
        }
        }
    }

    return undoMiddleware
}
