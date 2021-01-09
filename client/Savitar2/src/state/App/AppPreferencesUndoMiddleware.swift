//
//  AppPreferencesUndoMiddleware.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/4/21.
//  Copyright © 2021 Heynow Software. All rights reserved.
//

import Foundation
import ReSwift

class UndoableAppPreferencesStateAdapter: AppPreferencesUndoContext {
    let state: AppPreferencesState

    init(prefsState: AppPreferencesState) {
        state = prefsState
    }

    func continuousSpeechRate() -> Int {
        return state.prefs.continuousSpeechRate
    }
    
    func continuousSpeechVoice() -> String {
        return state.prefs.continuousSpeechVoice
    }
}

extension UndoCommand {
    convenience init?(appAction: AppPreferencesUndoableAction,
                      context: AppPreferencesUndoContext,
                      dispatch: @escaping DispatchFunction) {
        guard let inverseAction = appAction.inverse(context: context) else { return nil }

        self.init(undoBlock: { _ = dispatch(inverseAction.notUndoable) },
                  undoName: appAction.name,
                  redoBlock: { _ = dispatch(appAction.notUndoable) })
    }
}

func undoAppPreferencesStateMiddleware(undoManagerProvider: @escaping () -> UndoManager?) -> Middleware<AppPreferencesState> {
    func undoAction(action: AppPreferencesUndoableAction, state: AppPreferencesState,
                    dispatch: @escaping DispatchFunction) -> UndoCommand? {
        let context = UndoableAppPreferencesStateAdapter(prefsState: state)

        return UndoCommand(appAction: action, context: context, dispatch: dispatch)
    }
    let undoMiddleware: Middleware<AppPreferencesState> = { dispatch, getState in {
        next in {
            action in

            // Pass already undone actions through
            if let undoneAction = action as? NotUndoable {
                next(undoneAction.action)
                return
            }

            if let undoableAction = action as? AppPreferencesUndoableAction,
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
