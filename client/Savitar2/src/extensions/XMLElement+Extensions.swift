//
//  XMLElement+Extensions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/15/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation

extension XMLElement {
    func addAttribute(name: String, stringValue: String) {
        // TODO: need to do XML escaping for the stringValue?
        if let attrib = XMLNode.attribute(withName: name, stringValue: stringValue) as? XMLNode {
            addAttribute(attrib)
        }
    }
}
