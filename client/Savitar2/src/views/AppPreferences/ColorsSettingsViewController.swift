//
//  ColorsSettingsViewController.swift
//  Savitar2
//
//  Copyright © 2026 Heynow Software. All rights reserved.
//

import Cocoa

extension Notification.Name {
    // Posted when the global ANSI color palette changes so open sessions can restyle.
    static let savitarColorsChanged = Notification.Name("savitarColorsChanged")
}

class ColorsSettingsViewController: NSViewController {
    private var colorMan: ColorMan { AppContext.shared.prefs.colorMan }
    private var wells: [(well: NSColorWell, name: String)] = []

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        colorMan.installDefaultsIfNeeded()
        buildUI()
        syncWellsFromColorMan()
    }

    private func buildUI() {
        let grid = NSGridView()
        grid.translatesAutoresizingMaskIntoConstraints = false
        grid.rowSpacing = 6
        grid.columnSpacing = 12

        // Header row: blank corner + one column per shade.
        var headerViews: [NSView] = [NSGridCell.emptyContentView]
        for shade in AnsiColorShade.allCases {
            headerViews.append(columnHeader(shade.title))
        }
        grid.addRow(with: headerViews)

        // One row per hue, one color well per shade.
        for hue in AnsiColorName.allCases {
            var rowViews: [NSView] = [rowLabel(hue.title)]
            for shade in AnsiColorShade.allCases {
                let name = AnsiPalette.name(for: hue, shade: shade)
                let well = makeColorWell()
                wells.append((well, name))
                rowViews.append(well)
            }
            grid.addRow(with: rowViews)
        }

        // Align the shade columns' contents centered under their headers.
        for column in 1 ... AnsiColorShade.allCases.count {
            grid.column(at: column).xPlacement = .center
        }
        grid.column(at: 0).xPlacement = .trailing

        let restoreButton = NSButton(title: "Restore Defaults",
                                     target: self,
                                     action: #selector(restoreDefaultsAction(_:)))
        restoreButton.bezelStyle = .rounded
        restoreButton.translatesAutoresizingMaskIntoConstraints = false

        let stack = NSStackView(views: [grid, restoreButton])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
    }

    private func columnHeader(_ title: String) -> NSTextField {
        let label = NSTextField(labelWithString: title)
        label.font = NSFont.boldSystemFont(ofSize: NSFont.smallSystemFontSize)
        label.alignment = .center
        return label
    }

    private func rowLabel(_ title: String) -> NSTextField {
        NSTextField(labelWithString: title)
    }

    private func makeColorWell() -> NSColorWell {
        let well = NSColorWell()
        well.translatesAutoresizingMaskIntoConstraints = false
        well.target = self
        well.action = #selector(colorWellChanged(_:))
        NSLayoutConstraint.activate([
            well.widthAnchor.constraint(equalToConstant: 44),
            well.heightAnchor.constraint(equalToConstant: 24)
        ])
        return well
    }

    private func syncWellsFromColorMan() {
        for entry in wells {
            entry.well.color = colorMan.color(named: entry.name)
        }
    }

    @objc private func colorWellChanged(_ sender: NSColorWell) {
        guard let entry = wells.first(where: { $0.well === sender }) else { return }
        guard sender.color != colorMan.color(named: entry.name) else { return }
        apply([entry.name: sender.color], actionName: "Change Color")
    }

    @objc private func restoreDefaultsAction(_: Any) {
        let defaults = Dictionary(uniqueKeysWithValues: AnsiPalette.allNames.map {
            ($0, AnsiPalette.defaultColor(named: $0))
        })
        apply(defaults, actionName: "Restore Default Colors")
    }

    // Apply a set of color changes, registering the inverse with the window's undo manager so the
    // change can be undone and redone. `colorMan` isn't part of the ReSwift store, so undo is
    // handled directly here.
    private func apply(_ colors: [String: NSColor], actionName: String) {
        let inverse = snapshot(of: Array(colors.keys))
        for (name, color) in colors {
            colorMan.setColor(color, named: name)
        }
        syncWellsFromColorMan()

        if let undoManager = view.window?.undoManager {
            undoManager.registerUndo(withTarget: self) { target in
                target.apply(inverse, actionName: actionName)
            }
            undoManager.setActionName(actionName)
        }

        persistAndBroadcast()
    }

    private func snapshot(of names: [String]) -> [String: NSColor] {
        Dictionary(uniqueKeysWithValues: names.map { ($0, colorMan.color(named: $0)) })
    }

    private func persistAndBroadcast() {
        AppContext.shared.save()
        NotificationCenter.default.post(name: .savitarColorsChanged, object: nil)
    }
}
