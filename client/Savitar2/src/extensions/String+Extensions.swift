//
//  String+Extensions.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/25/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Foundation

extension String {
    var html2AttributedString: String? {
    guard let data = data(using: .utf8) else { return nil }
    do {
        return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil).string
    } catch let error as NSError {
        print(error.localizedDescription)
        return  nil
        }
    }

    func dropPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
