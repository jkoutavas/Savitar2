//
//  TriggerMan.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/4/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation
import SwiftyXMLParser

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
        for trigElem in xml["TRIGGERS"]["TRIGGER"] {
            let trigger = Trigger()
            try trigger.parse(xml: trigElem)
            add(trigger)
        }
    }

    func toXMLElement() throws -> XMLElement {
        return XMLElement() // TODO
    }
}
