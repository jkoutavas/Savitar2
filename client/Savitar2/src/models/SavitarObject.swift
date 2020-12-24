//
//  SavitarObject.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/5/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation
import SwiftyXMLParser

class SavitarObject: NSObject, SavitarXMLProtocol {
    let objectID: SavitarObjectID
    @objc dynamic var name = ""

    init(objectID: SavitarObjectID = SavitarObjectID()) {
        self.objectID = objectID
    }

    override init() {
        objectID = SavitarObjectID()
    }

    func parse(xml _: XML.Accessor) throws {}
    func toXMLElement() throws -> XMLElement {
        return XMLElement()
    }

    static func == (lhs: SavitarObject, rhs: SavitarObject) -> Bool {
        return lhs.objectID == rhs.objectID && lhs.name == rhs.name
    }
}
