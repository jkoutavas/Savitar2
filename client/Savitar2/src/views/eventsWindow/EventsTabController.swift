//
//  EventsTabController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 5/8/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

class EventsTabController: NSViewController, ReactionsStoreSetter {
    @IBOutlet var tableView: NSTableView!
    private var removeButton: NSButton?

    internal var store: ReactionsStore? {
        didSet {
            setStore(store)
        }
    }

    func setStore(_: ReactionsStore?) {
        fatalError("Must Override")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        installListControls()
    }

    @objc func addItem(_: Any) {}

    @objc func removeItem(_: Any) {}

    func setRemoveItemEnabled(_ enabled: Bool) {
        removeButton?.isEnabled = enabled
    }

    private func installListControls() {
        guard let scrollView = view as? NSScrollView else { return }

        let containerView = NSView(frame: scrollView.frame)
        containerView.autoresizingMask = view.autoresizingMask
        scrollView.autoresizingMask = []
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let addButton = NSButton(title: "Add", target: self, action: #selector(addItem(_:)))
        addButton.bezelStyle = .rounded
        addButton.toolTip = "Add a new \(itemName)"
        addButton.translatesAutoresizingMaskIntoConstraints = false

        let removeButton = NSButton(title: "Remove", target: self, action: #selector(removeItem(_:)))
        removeButton.bezelStyle = .rounded
        removeButton.isEnabled = false
        removeButton.toolTip = "Remove the selected \(itemName)"
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        self.removeButton = removeButton

        containerView.addSubview(scrollView)
        containerView.addSubview(addButton)
        containerView.addSubview(removeButton)
        view = containerView

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -8),

            addButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            addButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),

            removeButton.leadingAnchor.constraint(equalTo: addButton.trailingAnchor, constant: 8),
            removeButton.centerYAnchor.constraint(equalTo: addButton.centerYAnchor)
        ])
    }

    var itemName: String {
        return "item"
    }
}
