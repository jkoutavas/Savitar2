//
//  UndoActionContext.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/24/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

protocol UndoActionContext {
    func macroName(macroID: SavitarObjectID) -> String?
    func macroKey(macroID: SavitarObjectID) -> HotKey?
    func macroValue(macroID: SavitarObjectID) -> String?

    func triggerAppearance(triggerID: SavitarObjectID) -> TrigAppearance?
    func triggerAudioType(triggerID: SavitarObjectID) -> TrigAudioType?
    func triggerBackColor(triggerID: SavitarObjectID) -> NSColor?
    func triggerFace(triggerID: SavitarObjectID) -> TrigFace?
    func triggerForeColor(triggerID: SavitarObjectID) -> NSColor?
    func triggerMatching(triggerID: SavitarObjectID) -> TrigMatching?
    func triggerSpecifier(triggerID: SavitarObjectID) -> TrigSpecifier?
    func triggerSubstitution(triggerID: SavitarObjectID) -> String?
    func triggerType(triggerID: SavitarObjectID) -> TrigType?
    func triggerWordEnding(triggerID: SavitarObjectID) -> String?
    func triggerName(triggerID: SavitarObjectID) -> String?
}
