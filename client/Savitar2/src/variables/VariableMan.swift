//
//  VariableMan.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/25/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import SwiftyXMLParser

let VariablesElemIdentifier = "VARIABLES"

class VariableMan: SavitarManager<Variable>, SavitarXMLProtocol {

    //***************************
    // MARK: - SavitarXMLProtocol
    //***************************

    func parse(xml: XML.Accessor) throws {
         for elem in xml[VariablesElemIdentifier][VariableElemIdentifier] {
            let object = Variable()
            try object.parse(xml: elem)
            add(object)
        }
    }

    func toXMLElement() throws -> XMLElement {
        return try toXMLElement(groupId: VariablesElemIdentifier)
    }
}
