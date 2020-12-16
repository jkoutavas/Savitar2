//
//  SavitarObjectPasteboardWriter.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/3/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class SavitarObjectPasteboardWriter: NSObject, NSPasteboardWriting {
    var object: SavitarObject
    var index: Int

    init(object: SavitarObject, at index: Int) {
        self.object = object
        self.index = index
    }

    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return []
    }

    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        switch type {
        case .macro, .trigger:
            do {
                let elem = try object.toXMLElement().xmlString
                return elem
            } catch {
                return ""
            }
        case .tableViewIndex:
            return index
        default:
            return nil
        }
    }
}

extension NSPasteboard.PasteboardType {
    static let macro = NSPasteboard.PasteboardType("com.heynow.savitar.macro")
    static let trigger = NSPasteboard.PasteboardType("com.heynow.savitar.trigger")
    static let tableViewIndex = NSPasteboard.PasteboardType("com.heynow.savitar.tableViewIndex")
}

extension NSPasteboardItem {
    open func integer(forType type: NSPasteboard.PasteboardType) -> Int? {
        guard let data = data(forType: type) else { return nil }
        let plist = try? PropertyListSerialization.propertyList(
            from: data,
            options: .mutableContainers,
            format: nil)
        return plist as? Int
    }
}

class MacroPasteboardWriter: SavitarObjectPasteboardWriter {
    override func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.macro, .tableViewIndex]
    }
}

class TriggerPasteboardWriter: SavitarObjectPasteboardWriter {
    override func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.trigger, .tableViewIndex]
    }
}
