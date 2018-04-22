//
//  Document.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 2017-2018 Heynow Software. All rights reserved.
//

import Cocoa

class DocumentV2: Document {

    static let FileType = "com.heynow.savitar.world"

    override init() {
        super.init()
        world.version = 2
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func read(from data: Data, ofType typeName: String) throws {
        try super.read(from: data, ofType: typeName)
    }
 }
