//
//  TriggerMan.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/4/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation
import SwiftyXMLParser

let TriggersElemIdentifier = "TRIGGERS"

class TriggerMan: SavitarXMLProtocol {

    private var triggers: [Trigger] = []

    func add(_ trigger: Trigger) {
        triggers.append(trigger)
    }

    func get() -> [Trigger] {
        return triggers
    }

    //***************************
    // MARK: - SavitarXMLProtocol
    //***************************

    func parse(xml: XML.Accessor) throws {
        for trigElem in xml[TriggersElemIdentifier][TriggerElemIdentifier] {
            let trigger = Trigger()
            try trigger.parse(xml: trigElem)
            add(trigger)
        }
    }

    func toXMLElement() throws -> XMLElement {
        if triggers.count > 0 {
            let triggersElem = XMLElement(name: TriggersElemIdentifier)
            for trigger in triggers {
                let trigElem = try trigger.toXMLElement()
                triggersElem.addChild(trigElem)
            }

            return triggersElem
        } else {
            return XMLElement()
        }
    }
}
