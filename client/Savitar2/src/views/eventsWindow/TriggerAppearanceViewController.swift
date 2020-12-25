//
//  TriggerAppearanceViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 8/3/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class TriggerAppearanceViewController: NSViewController, StoreSubscriber {

    @IBOutlet weak var gagRadio: NSButton!
    @IBOutlet weak var dontAlterRadio: NSButton!
    @IBOutlet weak var changeRadio: NSButton!

    var trigger: Trigger?

    var store: ReactionsStore?
    func setStore(_ store: ReactionsStore?) {
        self.store = store
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        store?.subscribe(self)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        store?.unsubscribe(self)
    }

    @IBAction func appearanceRadioButtonChanged(_ sender: AnyObject) {
        guard let trigger = self.trigger else { return }

        if gagRadio.state == .on {
            store?.dispatch(TriggerAction.setAppearance(trigger.objectID, type: .gag))
        } else if dontAlterRadio.state == .on {
            store?.dispatch(TriggerAction.setAppearance(trigger.objectID, type: .dontUseStyle))
        } else {
            store?.dispatch(TriggerAction.setAppearance(trigger.objectID, type: .changeAppearance))
        }
    }

    @IBAction func backColorChanged(_ sender: AnyObject) {
        guard let trigger = self.trigger else { return }
        if let colorWell = sender as? NSColorWell {
            store?.dispatch(TriggerAction.setBackColor(trigger.objectID, color: colorWell.color))
        }
    }

    @IBAction func foreColorChanged(_ sender: AnyObject) {
        guard let trigger = self.trigger else { return }
        if let colorWell = sender as? NSColorWell {
            store?.dispatch(TriggerAction.setForeColor(trigger.objectID, color: colorWell.color))
        }
    }

    func newState(state: ReactionsState) {
        if let index = state.triggerList.selection, index < state.triggerList.items.count {
            let trigger = state.triggerList.items[index]
            self.trigger = trigger
            switch trigger.appearance {
            case .gag:
                gagRadio.state = .on
            case .dontUseStyle:
                dontAlterRadio.state = .on
            case .changeAppearance:
                changeRadio.state = .on
            }
            self.representedObject = TriggerAppearanceController(trigger: trigger, store: store)
        } else {
            self.representedObject = nil
        }
    }
}

class TriggerAppearanceController: NSController {
    var trigger: Trigger
    var store: ReactionsStore?
    var faceDescription: String

    @objc dynamic var backColorColor: NSColor {
        return trigger.style?.backColor ?? TrigFace.defaultBackColor
        // For unknown reasons, this setter doesn't get called. Have to use the backColorChanged outlet as a workaround
        //        set { store?.dispatch(TriggerAction.setBackColor(trigger.objectID, color: newValue)) }
    }

    @objc dynamic var backColorWellEnabled: Bool {
        guard let face = trigger.style?.face else { return false }
        return trigger.appearance == .changeAppearance && face.contains(.backColor)
    }

    @objc dynamic var foreColorColor: NSColor {
        return trigger.style?.foreColor ?? TrigFace.defaultForeColor
        // For unknown reasons, this setter doesn't get called. Have to use the foreColorChanged outlet as a workaround
        //       set { store?.dispatch(TriggerAction.setForeColor(trigger.objectID, color: newValue)) }
    }

    @objc dynamic var foreColorWellEnabled: Bool {
        guard let face = trigger.style?.face else { return false }
        return trigger.appearance == .changeAppearance && face.contains(.foreColor)
    }

    @objc dynamic var storeIsPresent: Bool {
        return store != nil
    }

    @objc dynamic var styleEnabled: Bool {
        return trigger.appearance == .changeAppearance
    }

    override func value(forUndefinedKey key: String) -> Any? {
        return faceDescription.contains(key)
    }

    override func setValue(_ value: Any?, forKeyPath keyPath: String) {
        let thisFace = TrigFace.from(string: keyPath)
        if var faces = trigger.style?.face {
            if faces.contains(thisFace) {
                faces.remove(thisFace)
            } else {
                faces.insert(thisFace)
            }
            store?.dispatch(TriggerAction.setFace(trigger.objectID, face: faces))
        } else {
            store?.dispatch(TriggerAction.setFace(trigger.objectID, face: thisFace))
        }
    }

    init(trigger: Trigger, store: ReactionsStore?) {
        self.trigger = trigger
        self.store = store
        self.faceDescription = trigger.style?.face?.description ?? ""

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
