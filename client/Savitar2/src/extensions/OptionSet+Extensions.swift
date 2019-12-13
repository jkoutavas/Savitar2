//
//  OptionSet+Extensions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/11/19.
//  Copyright © 2019 Heynow Software. All rights reserved.
//

import Foundation

// https://stackoverflow.com/questions/42588375/how-to-display-optionset-values-in-human-readable-form

protocol StrOptionSet: OptionSet, CustomStringConvertible {
    typealias Label = (Self, String)
    static var labels: [Label] { get } // used for going from set to string
    static var labelDict: [String: Self] { get } // used for going from string to set
}
extension StrOptionSet {
    var strs: [String] { return Self.labels
                                .filter { (label: Label) in self.isDisjoint(with: label.0) == false }
                                .map { (label: Label) in label.1 }
    }

    static public func from(string: String) -> Self {
        let components = string.components(separatedBy: "+")
        var result: Self = []
        for str in components {
            if let flag = Self.labelDict[str] {
                result = result.union(flag)
            }
        }

        return result
    }

    public var description: String { return strs.joined(separator: "+") }
}
