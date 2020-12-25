//
//  SavitarObjectId.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/22/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation

struct SavitarObjectID {
    let identifier: String

    init() {
        identifier = UUID().uuidString
    }

    init(UUID: Foundation.UUID) {
        identifier = UUID.uuidString
    }

    init?(identifier: String) {
        guard let UUID = UUID(uuidString: identifier) else {
            return nil
        }

        self.identifier = UUID.uuidString
    }
}

extension SavitarObjectID: Equatable {}

func == (lhs: SavitarObjectID, rhs: SavitarObjectID) -> Bool {
    return lhs.identifier == rhs.identifier
}

extension SavitarObjectID: Hashable {}

extension SavitarObjectID: CustomStringConvertible {
    var description: String { return identifier }
}
