//
//  TitledTableCellView.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/15/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class TitledItemViewModel: Codable {
    let identifier: String
    let title: String

    init(identifier: String, title: String) {
        self.identifier = identifier
        self.title = title
    }
}

class TitledTableCellView: NSTableCellView {
    var titleTextField: NSTextField! {
        get { return textField }
        set { textField = newValue }
    }

    var viewModel: CheckableItemViewModel! {
        didSet {
            titleTextField.stringValue = viewModel.title
        }
    }
}
