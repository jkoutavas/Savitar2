//
//  WorldSettingsWindowController.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

/// Modal World Settings window (`beginSheet` on the document window).
/// The settings window has its own title bar — keep the document title on the parent.
final class WorldSettingsWindowController: NSWindowController {
    weak var settingsController: WorldSettingsController?
    var parentDocumentTitle = ""

    private var escapeKeyMonitor: Any?

    override func windowDidLoad() {
        super.windowDidLoad()
        guard let window else { return }

        window.styleMask = [.titled, .closable, .resizable]
        window.title = title(for: .starting)
        if #available(macOS 11.0, *) {
            window.toolbarStyle = .preference
        }
        installEscapeKeyMonitor()
        updateForTab(.starting, animated: false)
    }

    deinit {
        if let escapeKeyMonitor {
            NSEvent.removeMonitor(escapeKeyMonitor)
        }
    }

    override func cancelOperation(_ sender: Any?) {
        settingsController?.cancelWorldSetting(sender as Any)
    }

    func updateForTab(_ tab: SavitarHelp.WorldSettingsTab, animated: Bool) {
        window?.title = title(for: tab)
        guard let window, let settingsController else { return }

        let contentSize = settingsController.fittingContentSize(for: tab)
        let width = max(contentSize.width, estimatedToolbarWidth(), 480)
        let height = max(contentSize.height, 260)

        let size = NSSize(width: width, height: height)
        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.15
                window.animator().setContentSize(size)
            }
        } else {
            window.setContentSize(size)
        }
        window.contentMinSize = NSSize(width: 480, height: 220)
    }

    private func installEscapeKeyMonitor() {
        escapeKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self, window?.isKeyWindow == true, event.keyCode == 53 else { return event }
            cancelOperation(self)
            return nil
        }
    }

    private func estimatedToolbarWidth() -> CGFloat {
        let font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        let iconWidth: CGFloat = 18
        let itemPadding: CGFloat = 20
        var width: CGFloat = 48
        for tab in SavitarHelp.WorldSettingsTab.allCases {
            let labelWidth = (tab.title as NSString).size(withAttributes: [.font: font]).width
            width += iconWidth + labelWidth + itemPadding
        }
        return ceil(width)
    }

    private func title(for tab: SavitarHelp.WorldSettingsTab) -> String {
        let tabTitle = tab.title
        guard !parentDocumentTitle.isEmpty else { return tabTitle }
        return "\(parentDocumentTitle) — \(tabTitle)"
    }
}
