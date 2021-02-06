//
//  AppPrefsViewController.swift
//  Savitar2
//
//  Created by Jay Koutavas on 2/5/21.
//  Copyright © 2021 Heynow Software. All rights reserved.
//

import Cocoa
import ReSwift

class AppPrefsViewController: NSViewController, StoreSubscriber {
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
        representedObject = AppPrefsPresenter(store: store!)
    }
}

class AppPrefsPresenter: NSObject {
    private var store: AppPreferencesStore

    init(store: AppPreferencesStore) {
        self.store = store
        super.init()
    }

    @objc dynamic var showStartupPicker: Bool {
        get { store.state.prefs.flags.contains(.startupPicker) }
        set { store.dispatch(SetShowStartupPickerAction(newValue)) }
    }
}
