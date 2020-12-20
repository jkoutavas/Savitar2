//
//  WorldViewModel.swift
//  Savitar2
//
//  Created by Jay Koutavas on 12/13/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Foundation

class WorldViewModel: TitledItemViewModel {

    init(world: World) {
        super.init(itemID: world.objectID.identifier, title:world.name)
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
