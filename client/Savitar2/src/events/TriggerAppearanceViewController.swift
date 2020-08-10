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
