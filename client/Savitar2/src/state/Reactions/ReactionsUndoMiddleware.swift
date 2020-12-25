//
//  ReactionsUndoMiddleware.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/29/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class UndoableReactionsStateAdapter: ReactionsUndoContext {
    let state: ReactionsState

    init(reactionsState: ReactionsState) {
        state = reactionsState
    }

    func macroListContext(macroID: SavitarObjectID) -> MacroListContext? {
        guard let index = state.macroList.indexOf(objectID: macroID),
              let macro = state.macroList.item(objectID: macroID)
        else { return nil }

        return (macro, index)
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

    func triggerListContext(triggerID: SavitarObjectID) -> TriggerListContext? {
        guard let index = state.triggerList.indexOf(objectID: triggerID),
              let trigger = state.triggerList.item(objectID: triggerID)
        else { return nil }

        return (trigger, index)
    }

    func triggerAppearance(triggerID: SavitarObjectID) -> TrigAppearance? {
        guard let trigger = state.triggerList.item(objectID: triggerID) else { return nil }
        return trigger.appearance
    }

    func triggerAudioType(triggerID: SavitarObjectID) -> TrigAudioType? {
        guard let trigger = state.triggerList.item(objectID: triggerID) else { return nil }
        return trigger.audioType
    }

    func triggerBackColor(triggerID: SavitarObjectID) -> NSColor? {
        guard let trigger = state.triggerList.item(objectID: triggerID) else { return nil }
        return trigger.style?.backColor
    }

    func triggerFace(triggerID: SavitarObjectID) -> TrigFace? {
        guard let trigger = state.triggerList.item(objectID: triggerID) else { return nil }
        return trigger.style?.face
    }

    func triggerForeColor(triggerID: SavitarObjectID) -> NSColor? {
        guard let trigger = state.triggerList.item(objectID: triggerID) else { return nil }
        return trigger.style?.foreColor
    }

    func triggerMatching(triggerID: SavitarObjectID) -> TrigMatching? {
        guard let trigger = state.triggerList.item(objectID: triggerID) else { return nil }
        return trigger.matching
    }

    func triggerName(triggerID: SavitarObjectID) -> String? {
        guard let trigger = state.triggerList.item(objectID: triggerID) else { return nil }
        return trigger.name
    }

    func triggerReplyText(triggerID: SavitarObjectID) -> String? {
        guard let trigger = state.triggerList.item(objectID: triggerID) else { return nil }
        return trigger.reply
    }

    func triggerSayText(triggerID: SavitarObjectID) -> String? {
        guard let trigger = state.triggerList.item(objectID: triggerID) else { return nil }
        return trigger.say
    }

    func triggerSound(triggerID: SavitarObjectID) -> String? {
        guard let trigger = state.triggerList.item(objectID: triggerID) else { return nil }
        return trigger.sound
    }

    func triggerSpecifier(triggerID: SavitarObjectID) -> TrigSpecifier? {
        guard let trigger = state.triggerList.item(objectID: triggerID) else { return nil }
        return trigger.specifier
    }

    func triggerSubstitution(triggerID: SavitarObjectID) -> String? {
        guard let trigger = state.triggerList.item(objectID: triggerID) else { return nil }
        return trigger.substitution
    }

    func triggerType(triggerID: SavitarObjectID) -> TrigType? {
        guard let trigger = state.triggerList.item(objectID: triggerID) else { return nil }
        return trigger.type
    }

    func triggerVoice(triggerID: SavitarObjectID) -> String? {
        guard let trigger = state.triggerList.item(objectID: triggerID) else { return nil }
        return trigger.voice
    }

    func triggerWordEnding(triggerID: SavitarObjectID) -> String? {
        guard let trigger = state.triggerList.item(objectID: triggerID) else { return nil }
        return trigger.wordEnding
    }
}

extension UndoCommand {
    convenience init?(appAction: ReactionUndoableAction,
                      context: ReactionsUndoContext,
                      dispatch: @escaping DispatchFunction) {
        guard let inverseAction = appAction.inverse(context: context)
        else { return nil }

        self.init(undoBlock: { _ = dispatch(inverseAction.notUndoable) },
                  undoName: appAction.name,
                  redoBlock: { _ = dispatch(appAction.notUndoable) })
    }
}

func undoReactionsStateMiddleware(undoManagerProvider: @escaping () -> UndoManager?) -> Middleware<ReactionsState> {
    func undoAction(action: ReactionUndoableAction, state: ReactionsState,
                    dispatch: @escaping DispatchFunction) -> UndoCommand? {
        let context = UndoableReactionsStateAdapter(reactionsState: state)

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

            if let undoableAction = action as? ReactionUndoableAction, undoableAction.isUndoable,
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
