//
//  TriggerMan.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/4/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import SwiftyXMLParser

let TriggersElemIdentifier = "TRIGGERS"

class TriggerMan: SavitarManager<Trigger>, SavitarXMLProtocol {

    //***************************
    // MARK: - SavitarXMLProtocol
    //***************************

    func parse(xml: XML.Accessor) throws {
         for elem in xml[TriggersElemIdentifier][TriggerElemIdentifier] {
            let object = Trigger()
            try object.parse(xml: elem)
            add(object)
        }
    }

    func toXMLElement() throws -> XMLElement {
        return try toXMLElement(groupId: TriggersElemIdentifier)
    }
}
