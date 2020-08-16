//
//  TriggerAudioCueViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 8/15/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class TriggerAudioCueViewController: NSViewController, StoreSubscriber {

    @IBOutlet var silentRadio: NSButton!
    @IBOutlet var soundRadio: NSButton!
    @IBOutlet var speakEventRadio: NSButton!
    @IBOutlet var sayTextRadio: NSButton!

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

    @IBAction func audioCueRadioButtonChanged(_ sender: AnyObject) {
        guard let trigger = self.trigger else { return }

        if silentRadio.state == .on {
            store?.dispatch(TriggerAction.setAudioType(trigger.objectID, type: .silent))
        } else if soundRadio.state == .on {
            store?.dispatch(TriggerAction.setAudioType(trigger.objectID, type: .sound))
        } else if speakEventRadio.state == .on {
            store?.dispatch(TriggerAction.setAudioType(trigger.objectID, type: .speakEvent))
        } else {
            store?.dispatch(TriggerAction.setAudioType(trigger.objectID, type: .sayText))
        }
    }

    func newState(state: ReactionsState) {
        if let index = state.triggerList.selection {
            let trigger = state.triggerList.items[index]
            self.trigger = trigger
            switch trigger.audioType {
            case .silent:
                silentRadio.state = .on
            case .sound:
                soundRadio.state = .on
            case .speakEvent:
                speakEventRadio.state = .on
            case .sayText:
                sayTextRadio.state = .on
            }
            self.representedObject = TriggerAudioCueController(trigger: trigger, store: store)
        } else {
            self.representedObject = nil
        }
    }
}

class TriggerAudioCueController: NSController {
    var trigger: Trigger
    var store: ReactionsStore?
    var faceDescription: String

    @objc dynamic var radioIsEnabled: Bool {
       return store != nil
    }

    @objc dynamic var soundPopUpIsEnabled: Bool {
        return store != nil && trigger.audioType == .sound
    }

    @objc dynamic var sayText: String {
        get { return trigger.say ?? "" }
        set { store?.dispatch(TriggerAction.setSayText(trigger.objectID, text: newValue)) }
    }

    @objc dynamic var speakerIsEnabled: Bool {
        return store != nil && trigger.audioType != .silent
    }

    @objc dynamic var textIsEnabled: Bool {
        return store != nil && trigger.audioType == .sayText
    }

    @objc dynamic var voicePopUpIsEnabled: Bool {
        return store != nil && trigger.audioType == .sayText
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
