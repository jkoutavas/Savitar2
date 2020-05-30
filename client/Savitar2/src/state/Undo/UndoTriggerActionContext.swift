//
//  UndoActionContext.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/24/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation

/// Exposes getters to easily query for the current state when creating
/// an `UndoCommand`.
///
/// It would've worked without this type, reaching deep into `ToDoListState`.
/// But then we would end up with very tight coupling.
protocol UndoTriggerActionContext {

    func triggerIn(triggerID: SavitarObjectID) -> TriggerIn?
}

typealias TriggerIn = (trigger: Trigger, index: Int)
