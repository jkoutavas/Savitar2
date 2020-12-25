//
//  String+Extensions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/25/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Foundation

extension String {
    func asciiAt(index: Int) -> UInt32? {
        let scalarIndex = unicodeScalars.index(unicodeScalars.startIndex, offsetBy: index)
        let scalar = unicodeScalars[scalarIndex]

        guard scalar.isASCII else {
            return nil
        }

        return scalar.value
    }

    func charAt(_ offset: Int) -> Character {
        let index = self.index(startIndex, offsetBy: offset) // BEWARE! This is O(n)
        return self[index]
    }

    func dropPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }

    func endsWithNewline() -> Bool {
        return hasSuffix("\n") || hasSuffix("\r")
    }

    // https://stackoverflow.com/a/53597089/246887
    public var expandingTildeInPath: String {
        return NSString(string: self).expandingTildeInPath
    }

    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }

    var fullRange: Range<String.Index> { return startIndex ..< endIndex }

    var html2AttributedString: String? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html,
                                                                .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil).string
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }

    func prettyXMLFormat() throws -> String {
        let xml = try XMLDocument(xmlString: self)
        let data = xml.xmlData(options: .nodePrettyPrint)
        if let str = String(data: data, encoding: .utf8) {
            return str
        } else {
            throw NSError()
        }
    }

    func ranges(of occurrence: String, options mask: String.CompareOptions = []) -> [Range<String.Index>] {
        var ranges = [Range<String.Index>]()
        var position = startIndex
        while let range = range(of: occurrence, options: mask, range: position ..< endIndex) {
            ranges.append(range)
            let offset = distance(from: range.lowerBound,
                                  to: range.upperBound) - 1
            guard let after = index(range.lowerBound,
                                    offsetBy: offset,
                                    limitedBy: endIndex) else {
                break
            }
            position = index(after: after)
        }
        return ranges
    }
}
