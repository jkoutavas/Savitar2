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
        return [DocumentV2.FileType]
    }
}
