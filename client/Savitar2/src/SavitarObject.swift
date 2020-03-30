//
//  SavitarObject.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/5/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import SwiftyXMLParser

class SavitarObject: Equatable, SavitarXMLProtocol {
    @objc dynamic var name = ""

    func parse(xml: XML.Accessor) throws {}
    func toXMLElement() throws -> XMLElement {
        return XMLElement()
    }

    static func == (lhs: SavitarObject, rhs: SavitarObject) -> Bool {
        return lhs.name == rhs.name
    }
}
