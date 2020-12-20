//
//  ModelManager.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/22/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation
import SwiftyXMLParser

class ModelManager<Object: SavitarObject> {
    var undoManager: UndoManager?

    private var objects: [Object]

    init(_ objects: [Object] = []) {
        self.objects = objects
    }

    func add(_ object: Object) {
        objects.append(object)
    }

    func get() -> [Object] {
        return objects
    }

    func set(index: Int, object: Object) {
        objects[index] = object
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