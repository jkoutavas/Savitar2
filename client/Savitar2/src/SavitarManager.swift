//
//  SavitarManager.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/22/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import SwiftyXMLParser

class SavitarManager<Object: SavitarObject> {
    var name = ""
    private var objects: [Object] = []

    func add(_ object: Object) {
        objects.append(object)
    }

    func get() -> [Object] {
        return objects
    }
    
    func remove(_ object: Object) {
        objects.remove(object: object)
    }

    func toXMLElement(groupId: String) throws -> XMLElement {
        if objects.count > 0 {
            let objectsElem = XMLElement(name: groupId)
            for object in objects {
                let objectElem = try object.toXMLElement()
                objectsElem.addChild(objectElem)
            }
            return objectsElem
        } else {
            return XMLElement()
        }
    }
}
