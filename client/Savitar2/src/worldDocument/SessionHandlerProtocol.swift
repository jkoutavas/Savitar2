//
//  SessionHandlerProtocol.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/13/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Foundation

// TODO: eventually may want to move this into its own module
enum Result<T, E> {
    case success(T)
    case error(E)
}

typealias OutputResult = Result<String, String>

enum SessionTriggerScope {
    case world
    case universal
}

protocol SessionHandlerProtocol {
    func connectionStatusChanged(status: ConnectionStatus)
    func output(result: OutputResult)
    func printSource()
    func commandHistory() -> [String]
    func setSessionStatus(pane: SessionStatusPane, text: String)
    func closeSessionStatusBars()
    func closeSessionStatus(pane: SessionStatusPane)
    func recallCommand(at index: Int)
    func clearOutputScreen()
    func refreshSessionDisplay()
    func insertWorldTrigger(_ trigger: Trigger)
    func insertWorldMacro(_ macro: Macro)
    func syncTriggerEnabled(_ trigger: Trigger, scope: SessionTriggerScope, enabled: Bool)
    func worldTriggers() -> [Trigger]
    func worldMacros() -> [Macro]
}

extension SessionHandlerProtocol {
    func closeSessionStatus(pane _: SessionStatusPane) {}
    func recallCommand(at _: Int) {}
    func clearOutputScreen() {}
    func refreshSessionDisplay() {}
    func insertWorldTrigger(_: Trigger) {}
    func insertWorldMacro(_: Macro) {}
    func syncTriggerEnabled(_: Trigger, scope _: SessionTriggerScope, enabled _: Bool) {}
    func worldTriggers() -> [Trigger] { return [] }
    func worldMacros() -> [Macro] { return [] }
}
