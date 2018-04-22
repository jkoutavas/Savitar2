//
//  DocumentV1.swift
//  Savitar2
//
//  Created by Jay Koutavas on 11/21/17.
//  Copyright © 2017-2018 Heynow Software. All rights reserved.
//

import Cocoa

class DocumentV1: Document {

      override init() {
        super.init()
        world.version = 1
    }

    override class var autosavesInPlace: Bool {
        return false
    }

    override func writableTypes(for saveOperation: NSDocument.SaveOperationType) -> [String] {
        // we only Save As v2
        return [DocumentV2.FileType]
    }

    override func duplicate() throws -> NSDocument {
        // switch over to v2 document type when duplicating
        fileType = DocumentV2.FileType
        return try super.duplicate()
    }
}
