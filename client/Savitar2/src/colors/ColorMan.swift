//
//  ColorMan.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/25/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import SwiftyXMLParser

let ColorsElemIdentifier = "COLORS"

class ColorMan: SavitarManager<SavColor>, SavitarXMLProtocol {

    //***************************
    // MARK: - SavitarXMLProtocol
    //***************************

    func parse(xml: XML.Accessor) throws {
         for elem in xml[ColorsElemIdentifier][ColorElemIdentifier] {
            let object = SavColor()
            try object.parse(xml: elem)
            add(object)
        }
    }

    func toXMLElement() throws -> XMLElement {
        return try toXMLElement(groupId: ColorsElemIdentifier)
    }
}
