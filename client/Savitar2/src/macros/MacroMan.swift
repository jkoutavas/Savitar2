//
//  MacroMan.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/25/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation
import SwiftyXMLParser

let MacrosElemIdentifier = "VARIABLES" // yes, the original v1.x Savitar's macro list was labeled VARIABLES

class MacroMan: ModelManager<Macro>, SavitarXMLProtocol {

    //***************************
    // MARK: - SavitarXMLProtocol
    //***************************

    func parse(xml: XML.Accessor) throws {
         for elem in xml[MacrosElemIdentifier][MacroElemIdentifier] {
            let object = Macro()
            try object.parse(xml: elem)
            add(object)
        }
    }

    func toXMLElement() throws -> XMLElement {
        return try toXMLElement(groupId: MacrosElemIdentifier)
    }
}
