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
    
    func newState(state: AppPreferencesState) {
        representedObject = SpeechPrefsPresenter(store: store!)
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
}
