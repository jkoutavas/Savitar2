//
//  CheckableTableCellView.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/15/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class CheckableItemViewModel: Codable {
    let identifier: String
    let enabled: Bool
    let title: String

    init(identifier: String, title: String, enabled: Bool) {
        self.identifier = identifier
        self.title = title
        self.enabled = enabled
    }
}

@objc protocol CheckableItemChangeDelegate: class {
    func checkableItem(identifier: String, didChangeChecked checked: Bool)
}

class CheckableTableCellView: NSTableCellView {
    @IBOutlet var checkbox: CheckBox!

    weak var checkableItemChangeDelegate: CheckableItemChangeDelegate?

    var titleTextField: NSTextField! {
        get { return textField }
        set { textField = newValue }
    }

    var viewModel: CheckableItemViewModel! {
        didSet {
            titleTextField.stringValue = viewModel.title
            checkbox.checked = viewModel.enabled
        }
    }

    @IBAction func checkboxChanged(_ sender: AnyObject) {
        // TODO
    }
}
