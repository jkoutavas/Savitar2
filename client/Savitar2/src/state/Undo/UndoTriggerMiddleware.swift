//
//  UndoTriggerMiddleware.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/29/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

class UndoableStateAdapter: UndoTriggerActionContext {

    let state: ReactionsState

    init(reactionsState: ReactionsState) {
        state = reactionsState
    }

    func triggerIn(triggerID: SavitarObjectID) -> TriggerIn? {
        guard let index = state.triggerList.items.firstIndex(where: { $0.objectID == triggerID })
        else { return nil }

        let trigger = state.triggerList.items[index]
        return (trigger, index)
    }
}

extension UndoCommand {
    convenience init?(appAction: UndoableAction, context: UndoTriggerActionContext, dispatch: @escaping DispatchFunction) {
        guard let inverseAction = appAction.inverse(context: context)
        else { return nil }

        self.init(undoBlock: { _ = dispatch(inverseAction.notUndoable) },
                  undoName: appAction.name,
                  redoBlock: { _ = dispatch(appAction.notUndoable) })
    }
}

func undoTriggerMiddleware(undoManager: UndoManager) -> Middleware<ReactionsState> {
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
                    let undo = undoAction(action: undoableAction, state: state, dispatch: dispatch) {
                    undo.register(undoManager: undoManager)
                }

                next(action)
            }
        }
    }

    return undoMiddleware
}
