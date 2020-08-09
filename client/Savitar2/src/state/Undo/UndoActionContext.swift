//
//  UndoActionContext.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/24/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation

protocol UndoActionContext {
    func macroName(macroID: SavitarObjectID) -> String?
    func macroKey(macroID: SavitarObjectID) -> HotKey?
    func macroValue(macroID: SavitarObjectID) -> String?

    func triggerMatching(triggerID: SavitarObjectID) -> TrigMatching?
    func triggerSpecifier(triggerID: SavitarObjectID) -> TrigSpecifier?
    func triggerSubstitution(triggerID: SavitarObjectID) -> String?
    func triggerType(triggerID: SavitarObjectID) -> TrigType?
    func triggerWordEnding(triggerID: SavitarObjectID) -> String?
    func triggerName(triggerID: SavitarObjectID) -> String?
}
