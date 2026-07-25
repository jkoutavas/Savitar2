//
//  WorldSettingsController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 4/15/18.
//  Copyright © 2018 Heynow Software. All rights reserved.
//

import Cocoa

class WorldSettingsController: NSViewController {
    var completionHandler: ((Bool, World?) -> Void)?

    weak var sheetWindowController: WorldSettingsWindowController?

    var world: World? {
        get {
            return _editedWorld
        }
        set {
            // copy the world. We'll manipulate it in settings, and if the
            // user hits 'apply' we'll copy the changes back.
            guard let world = newValue?.copy() as? World else { return }
            _editedWorld = world

            // we set the tab controllers' world here in the world setter
            // instead of prepare(for segue:) because prepare(for segue:)
            // gets called at storyboard instantiation, before we have
            // the chance to set the world value
            if let tvc = _tabViewController {
                for viewItem in tvc.tabViewItems {
                    viewItem.viewController?.representedObject = _editedWorld!
                }
            }
        }
    }

    private var _editedWorld: World?
    private var _tabViewController: NSTabViewController?
    private var tabIndexObservation: NSKeyValueObservation?
    private var didPolishChrome = false

    private let footerHeight: CGFloat = 72

    override func prepare(for segue: NSStoryboardSegue, sender _: Any?) {
        // grab a reference to the tabViewController, we'll use it in the
        // world setter to propagate the world down into the tab controllers
        if segue.destinationController is NSTabViewController {
            _tabViewController = segue.destinationController as? NSTabViewController
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        sheetWindowController = view.window?.windowController as? WorldSettingsWindowController
        sheetWindowController?.settingsController = self
        if let tvc = _tabViewController {
            tabIndexObservation = tvc.observe(\.selectedTabViewItemIndex) { [weak self] _, _ in
                self?.tabSelectionDidChange()
            }
        }
        tabSelectionDidChange()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        polishChromeForHIGIfNeeded()
    }

    deinit {
        tabIndexObservation?.invalidate()
    }

    @IBAction func applyWorldSetting(_: Any) {
        completionHandler?(true, _editedWorld)
    }

    @IBAction func cancelWorldSetting(_: Any) {
        completionHandler?(false, nil)
    }

    func fittingContentSize(for tab: SavitarHelp.WorldSettingsTab) -> NSSize {
        let width: CGFloat = 480
        let preferredTabHeight = tab.preferredSheetHeight
        var tabHeight = preferredTabHeight
        if let tabView = _tabViewController?.tabViewItems[tab.rawValue].view {
            tabView.layoutSubtreeIfNeeded()
            let fitted = tabView.fittingSize
            if fitted.height > 1 {
                tabHeight = max(fitted.height, preferredTabHeight)
            }
        }
        return NSSize(width: max(width, tabViewWidth(for: tab)), height: tabHeight + footerHeight)
    }

    private func tabViewWidth(for tab: SavitarHelp.WorldSettingsTab) -> CGFloat {
        guard let tabView = _tabViewController?.tabViewItems[tab.rawValue].view else { return 0 }
        return tabView.fittingSize.width
    }

    private func tabSelectionDidChange() {
        polishChromeForHIGIfNeeded()
        updateContextualHelpForSelectedTab()
        let tab = selectedWorldSettingsTab ?? .starting
        sheetWindowController?.updateForTab(tab, animated: view.window?.isVisible == true)
    }

    private func polishChromeForHIGIfNeeded() {
        guard !didPolishChrome else { return }
        didPolishChrome = true

        for subview in view.subviews {
            if let field = subview as? NSTextField,
               field.cell?.title == "Settings",
               field.alignment == .center {
                field.isHidden = true
                for constraint in view.constraints where
                    (constraint.firstItem as? NSObject) === field && constraint.firstAttribute == .height {
                    constraint.constant = 0
                }
            }
            if let button = subview as? NSButton, button.title == "Apply" {
                button.title = "OK"
                button.keyEquivalent = "\r"
            }
        }
    }

    private func updateContextualHelpForSelectedTab() {
        let tab = selectedWorldSettingsTab ?? .starting
        SavitarHelpButton.installInTopTrailingCorner(of: view, for: .worldSettings(tab))
    }

    private var selectedWorldSettingsTab: SavitarHelp.WorldSettingsTab? {
        guard let index = _tabViewController?.selectedTabViewItemIndex else { return nil }
        return SavitarHelp.WorldSettingsTab(rawValue: index)
    }

    var currentWorldSettingsTab: SavitarHelp.WorldSettingsTab {
        selectedWorldSettingsTab ?? .starting
    }
}

private extension SavitarHelp.WorldSettingsTab {
    var preferredSheetHeight: CGFloat {
        switch self {
        case .starting: return 400
        case .appearance: return 520
        case .input: return 480
        case .output: return 300
        case .closing: return 380
        }
    }
}
