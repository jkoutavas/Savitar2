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

    @IBOutlet var gagRadio: NSButton!
    @IBOutlet var dontAlterRadio: NSButton!
    @IBOutlet var changeRadio: NSButton!

    var trigger: Trigger?

    var store: ReactionsStore?
    func setStore(reactionsStore: ReactionsStore?) {
        store = reactionsStore
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
            store?.dispatch(TriggerAction.setAppearance(trigger.objectID, appearance: .gag))
        } else if dontAlterRadio.state == .on {
            store?.dispatch(TriggerAction.setAppearance(trigger.objectID, appearance: .dontUseStyle))
        } else {
            store?.dispatch(TriggerAction.setAppearance(trigger.objectID, appearance: .changeAppearance))
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
        if let index = state.triggerList.selection {
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
        get { return trigger.style?.backColor ?? NSColor.black }
        // For unknown reasons, this setter doesn't get called. Have to use the backColorChanged outlet as a workaround
//        set { store?.dispatch(TriggerAction.setBackColor(trigger.objectID, color: newValue)) }
    }

    @objc dynamic var backColorWellEnabled: Bool {
        get {
            guard let face = trigger.style?.face else { return false }
            return trigger.appearance == .changeAppearance && face.contains(.backColor)
        }
    }

    @objc dynamic var foreColorColor: NSColor {
        get { return trigger.style?.foreColor ?? NSColor.white }
        // For unknown reasons, this setter doesn't get called. Have to use the foreColorChanged outlet as a workaround
 //       set { store?.dispatch(TriggerAction.setForeColor(trigger.objectID, color: newValue)) }
    }

    @objc dynamic var foreColorWellEnabled: Bool {
        get {
            guard let face = trigger.style?.face else { return false }
            return trigger.appearance == .changeAppearance && face.contains(.foreColor)
        }
     }

    @objc dynamic var styleEnabled: Bool {
        get { return trigger.appearance == .changeAppearance }
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
