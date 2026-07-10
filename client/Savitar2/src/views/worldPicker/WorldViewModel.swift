//
//  WorldViewModel.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/13/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation

class WorldViewModel: TitledItemViewModel {
    let hostSummary: String

    init(world: World) {
        hostSummary = WorldViewModel.hostSummary(for: world)
        super.init(itemID: world.objectID.identifier, title: world.name)
    }

    private static func hostSummary(for world: World) -> String {
        if world.host.isEmpty {
            return "No address configured"
        }
        return "\(world.host):\(world.port)"
    }

    required init(from _: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
