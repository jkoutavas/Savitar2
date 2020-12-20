//
//  TitledTableCellView.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/15/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class TitledItemViewModel: Codable {
    let itemID: String
    let title: String

    init(itemID: String, title: String) {
        self.itemID = itemID
        self.title = title
    }
}

class TitledTableCellView: NSTableCellView {
    var titleTextField: NSTextField! {
        get { return textField }
        set { textField = newValue }
    }

    var itemID: String = ""

    func updateContent(viewModel: TitledItemViewModel) {
        titleTextField.stringValue = viewModel.title
        itemID = viewModel.itemID
    }
}
