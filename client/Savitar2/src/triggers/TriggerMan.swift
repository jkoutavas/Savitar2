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

class TriggerMan: ModelManager<Trigger>, SavitarXMLProtocol {

    //***************************
    // MARK: - SavitarXMLProtocol
    //***************************

    func parse(xml: XML.Accessor) throws {
        for elem in xml[TriggersElemIdentifier][TriggerElemIdentifier] {
            let trigger = Trigger()
            try trigger.parse(xml: elem)

            /*
             * For perfomance reasons, formulate the on and off escape sequences as they are set
             */
            if trigger.style != nil {
                trigger.style!.formOnOff()
            }

            add(trigger)
        }
    }

    func toXMLElement() throws -> XMLElement {
        return try toXMLElement(groupId: TriggersElemIdentifier)
    }
}
