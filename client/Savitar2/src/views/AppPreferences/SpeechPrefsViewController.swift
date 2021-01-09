//
//  SpeechPrefsViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 1/3/21.
//  Copyright © 2021 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class SpeechPrefsViewController: NSViewController, StoreSubscriber {
    var store: AppPreferencesStore?

    override func viewWillAppear() {
        super.viewWillAppear()

        store?.subscribe(self)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()

        store?.unsubscribe(self)
    }

    func newState(state _: AppPreferencesState) {
        representedObject = SpeechPrefsPresenter(store: store!)
    }
    
    @objc dynamic var voiceNames: [String] {
        return AppContext.shared.speakerMan.voiceNames()
    }
    
    @IBAction func speakerButtonAction(_: AnyObject) {
        AppContext.shared.speakerMan.speak(text: "The rain falls mainly in the plain.",
                                           voiceName: AppContext.shared.prefs.continuousSpeechVoice)
    }
}

class SpeechPrefsPresenter: NSObject {
    private var store: AppPreferencesStore

    init(store: AppPreferencesStore) {
        self.store = store
        super.init()
    }

    @objc dynamic var hasContinuousSpeech: Bool { AppContext.hasContinuousSpeech() }

    @objc dynamic var enabled: Bool {
        get { store.state.prefs.continuousSpeechEnabled }
        set { store.dispatch(SetContinuousSpeechEnabledAction(newValue)) }
    }

    @objc dynamic var rate: Int {
        get { store.state.prefs.continuousSpeechRate }
        set { store.dispatch(SetContinuousSpeechRateAction(newValue)) }
    }
    
    @objc dynamic var voiceIndex: Int {
        get {
            let voiceName = AppContext.shared.prefs.continuousSpeechVoice
            let voiceNames = AppContext.shared.speakerMan.voiceNames()
            let index = voiceName.count > 0 ? voiceNames.firstIndex(of: voiceName) : 0
            return index ?? 0
        }
        set {
            let voiceNames = AppContext.shared.speakerMan.voiceNames()
            store.dispatch(SetContinuousSpeechVoiceAction(voiceNames[newValue]))
        }
    }
}
