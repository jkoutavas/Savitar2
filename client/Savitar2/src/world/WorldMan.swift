//
//  WorldMan.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/20/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation
import SwiftyXMLParser

let WorldsElemIdentifier = "WORLDS"

class WorldMan: ModelManager<World>, SavitarXMLProtocol {

    //***************************
    // MARK: - SavitarXMLProtocol
    //***************************

    func parse(xml: XML.Accessor) throws {
         for elem in xml[WorldsElemIdentifier][WorldElemIdentifier] {
            let object = World()
            try object.parse(xml: elem)
            add(object)
        }
    }

    func toXMLElement() throws -> XMLElement {
        return try toXMLElement(groupId: WorldsElemIdentifier)
    }
}
