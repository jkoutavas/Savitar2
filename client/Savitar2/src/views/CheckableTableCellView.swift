//
//  CheckableTableCellView.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/15/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class CheckableItemViewModel: TitledItemViewModel {
    let enabled: Bool

    init(itemID: String, title: String, enabled: Bool) {
        self.enabled = enabled
        super.init(itemID: itemID, title: title)
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

@objc protocol CheckableItemChangeDelegate: class {
    func checkableItem(itemID: String, didChangeChecked checked: Bool)
}

class CheckableTableCellView: TitledTableCellView {
    @IBOutlet weak var checkbox: CheckBox!

    weak var checkableItemChangeDelegate: CheckableItemChangeDelegate?

    func updateContent(viewModel: CheckableItemViewModel) {
        super.updateContent(viewModel: viewModel)
        checkbox.checked = viewModel.enabled
    }

    @IBAction func checkboxChanged(_ sender: AnyObject) {
        checkableItemChangeDelegate?.checkableItem(itemID: itemID, didChangeChecked: checkbox.checked)
    }
}
