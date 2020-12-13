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

    init(identifier: String, title: String, enabled: Bool) {
        self.enabled = enabled
        super.init(identifier: identifier, title: title)
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

@objc protocol CheckableItemChangeDelegate: class {
    func checkableItem(identifier: String, didChangeChecked checked: Bool)
}

class CheckableTableCellView: TitledTableCellView {
    @IBOutlet weak var checkbox: CheckBox!

    weak var checkableItemChangeDelegate: CheckableItemChangeDelegate?

    override var viewModel: CheckableItemViewModel! {
        didSet {
            titleTextField.stringValue = viewModel.title
            checkbox.checked = viewModel.enabled
        }
    }

    @IBAction func checkboxChanged(_ sender: AnyObject) {
        checkableItemChangeDelegate?.checkableItem(identifier: viewModel.identifier, didChangeChecked: checkbox.checked)
    }
}
