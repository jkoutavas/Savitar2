//
//  WorldsUndoMiddleware.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/19/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

class UndoableWorldsStateAdapter: WorldsUndoContext {
    let state: WorldsState

    init(worldsState: WorldsState) {
        state = worldsState
    }

    func worldListContext(worldID: SavitarObjectID) -> WorldListContext? {
        guard let index = state.worldList.indexOf(objectID: worldID),
              let world = state.worldList.item(objectID: worldID)
        else { return nil }

        return (world, index)
    }

    func worldName(worldID: SavitarObjectID) -> String? {
        return state.worldList.item(objectID: worldID)?.name
    }
}

extension UndoCommand {
    convenience init?(appAction: WorldUndoableAction,
                      context: WorldsUndoContext,
                      dispatch: @escaping DispatchFunction) {
        guard let inverseAction = appAction.inverse(context: context)
        else { return nil }

        self.init(undoBlock: { _ = dispatch(inverseAction.notUndoable) },
                  undoName: appAction.name,
                  redoBlock: { _ = dispatch(appAction.notUndoable) })
    }
}

func undoWorldsStateMiddleware(undoManagerProvider: @escaping () -> UndoManager?) -> Middleware<WorldsState> {
    func undoAction(action: WorldUndoableAction, state: WorldsState,
                    dispatch: @escaping DispatchFunction) -> UndoCommand? {
        let context = UndoableWorldsStateAdapter(worldsState: state)

        return UndoCommand(appAction: action, context: context, dispatch: dispatch)
    }
    let undoMiddleware: Middleware<WorldsState> = { dispatch, getState in {
        next in {
            action in

            // Pass already undone actions through
            if let undoneAction = action as? NotUndoable {
                next(undoneAction.action)
                return
            }

            if let undoableAction = action as? WorldUndoableAction,
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
