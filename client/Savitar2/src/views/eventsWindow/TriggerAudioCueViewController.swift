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

    let currentSoundNames = AppContext.shared.speakerMan.soundNames()
    let currentVoiceNames = AppContext.shared.speakerMan.voiceNames()

    @objc dynamic var soundNames: [String] {
        return currentSoundNames
    }

    @objc dynamic var voiceNames: [String] {
        return AppContext.shared.speakerMan.voiceNames()
    }

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

    @IBAction func audioCueRadioButtonChanged(_: AnyObject) {
        guard let trigger = self.trigger else { return }

        if silentRadio.state == .on {
            store?.dispatch(TriggerAction.setAudioType(trigger.objectID, type: .silent))
        } else if soundRadio.state == .on {
            store?.dispatch(TriggerAction.setAudioType(trigger.objectID, type: .sound))
            if trigger.sound == nil, soundNames.count > 0 {
                store?.dispatch(TriggerAction.setSound(trigger.objectID, name: soundNames[0]))
            }
        } else if speakEventRadio.state == .on {
            store?.dispatch(TriggerAction.setAudioType(trigger.objectID, type: .speakEvent))
            if trigger.voice == nil, currentVoiceNames.count > 0 {
                store?.dispatch(TriggerAction.setVoice(trigger.objectID, name: voiceNames[0]))
            }
        } else {
            store?.dispatch(TriggerAction.setAudioType(trigger.objectID, type: .sayText))
            if trigger.voice == nil, currentVoiceNames.count > 0 {
                store?.dispatch(TriggerAction.setVoice(trigger.objectID, name: voiceNames[0]))
            }
        }
    }

    @IBAction func speakerButtonAction(_: AnyObject) {
        if let trigger = self.trigger {
            AppContext.shared.speakerMan.playAudio(trigger: trigger)
        }
    }

    func newState(state: ReactionsState) {
        if let index = state.triggerList.selection, index < state.triggerList.items.count {
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
            representedObject =
                TriggerAudioCueController(trigger: trigger, store: store, soundNames: currentSoundNames,
                                          voiceNames: currentVoiceNames)
        } else {
            representedObject = nil
        }
    }
}

class TriggerAudioCueController: NSController {
    var trigger: Trigger
    var store: ReactionsStore?
    var soundNames: [String]
    var voiceNames: [String]

    @objc dynamic var radioIsEnabled: Bool {
        return store != nil
    }

    @objc dynamic var soundIndex: Int {
        get {
            guard let soundName = trigger.sound else { return 0 }
            let index = soundNames.firstIndex(of: soundName)
            return index ?? 0
        }
        set { store?.dispatch(TriggerAction.setSound(trigger.objectID, name: soundNames[newValue])) }
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

    @objc dynamic var voiceIndex: Int {
        get {
            guard let voiceName = trigger.voice else { return 0 }
            let index = voiceNames.firstIndex(of: voiceName)
            return index ?? 0
        }
        set { store?.dispatch(TriggerAction.setVoice(trigger.objectID, name: voiceNames[newValue])) }
    }

    @objc dynamic var voicePopUpIsEnabled: Bool {
        return store != nil && trigger.audioType == .sayText
    }

    init(trigger: Trigger, store: ReactionsStore?, soundNames: [String], voiceNames: [String]) {
        self.trigger = trigger
        self.store = store
        self.soundNames = soundNames
        self.voiceNames = voiceNames

        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
