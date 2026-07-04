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

    private var continuousSpeechCheckbox: NSButton?
    private var voicePopup: NSPopUpButton?
    private var speakerButton: NSButton?
    private var rateSlider: NSSlider?
    private var speakingBox: NSBox?
    private var isSubscribed = false

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        populateVoiceMenu()
        syncControlsFromStore()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        activateIfNeeded()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        store?.unsubscribe(self)
        isSubscribed = false
    }

    func activateIfNeeded() {
        guard store != nil else { return }
        if !isSubscribed, let store {
            store.subscribe(self)
            isSubscribed = true
        }
        populateVoiceMenu()
        syncControlsFromStore()
    }

    func newState(state _: AppPreferencesState) {
        syncControlsFromStore()
    }

    @IBAction func speakerButtonAction(_: AnyObject) {
        AppContext.shared.speakerMan.speak(text: "The rain falls mainly in the plain.",
                                           voiceName: AppContext.shared.prefs.continuousSpeechVoice)
    }

    @objc private func continuousSpeechToggled(_ sender: NSButton) {
        guard let store else { return }
        let enabled = sender.state == .on
        if enabled {
            ensureDefaultVoiceSaved()
        }
        store.dispatch(SetContinuousSpeechEnabledAction(enabled))
        syncControlEnabledState()
    }

    @objc private func voiceSelectionChanged(_ sender: NSPopUpButton) {
        guard let store else { return }
        let names = AppContext.shared.speakerMan.voiceNames()
        guard sender.indexOfSelectedItem >= 0, sender.indexOfSelectedItem < names.count else { return }
        store.dispatch(SetContinuousSpeechVoiceAction(names[sender.indexOfSelectedItem]))
        AppContext.shared.save()
    }

    @objc private func rateChanged(_ sender: NSSlider) {
        guard let store else { return }
        store.dispatch(SetContinuousSpeechRateAction(sender.integerValue))
        AppContext.shared.save()
    }

    private func buildUI() {
        let stack = NSStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 10

        let checkbox = NSButton(checkboxWithTitle: "Continuous speech enabled",
                                target: self,
                                action: #selector(continuousSpeechToggled(_:)))
        checkbox.isEnabled = AppContext.hasContinuousSpeech()
        continuousSpeechCheckbox = checkbox
        stack.addArrangedSubview(checkbox)

        if !AppContext.hasContinuousSpeech() {
            let footnote = NSTextField(labelWithString: "(requires macOS 10.15 or later)")
            footnote.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
            footnote.textColor = .secondaryLabelColor
            stack.addArrangedSubview(footnote)
        }

        let voiceRow = NSStackView()
        voiceRow.orientation = .horizontal
        voiceRow.alignment = .centerY
        voiceRow.spacing = 8
        voiceRow.addArrangedSubview(NSTextField(labelWithString: "Voice:"))

        let popup = NSPopUpButton(frame: .zero, pullsDown: false)
        popup.target = self
        popup.action = #selector(voiceSelectionChanged(_:))
        popup.setContentHuggingPriority(.defaultLow, for: .horizontal)
        popup.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        voicePopup = popup
        voiceRow.addArrangedSubview(popup)

        let speakerImage = NSImage(speakerSymbolName: "speaker.wave.2.fill",
                                   accessibilityDescription: "Play sample voice")
            ?? NSImage(named: NSImage.touchBarAudioOutputVolumeHighTemplateName)
        let speaker = NSButton(image: speakerImage ?? NSImage(), target: self,
                               action: #selector(speakerButtonAction(_:)))
        speaker.bezelStyle = .regularSquare
        speaker.isBordered = false
        speakerButton = speaker
        voiceRow.addArrangedSubview(speaker)
        stack.addArrangedSubview(voiceRow)

        let box = NSBox()
        box.title = "All speaking"
        box.boxType = .primary
        speakingBox = box

        let rateStack = NSStackView()
        rateStack.orientation = .vertical
        rateStack.alignment = .leading
        rateStack.spacing = 6
        rateStack.translatesAutoresizingMaskIntoConstraints = false

        let rateRow = NSStackView()
        rateRow.orientation = .horizontal
        rateRow.alignment = .centerY
        rateRow.spacing = 8
        rateRow.addArrangedSubview(NSTextField(labelWithString: "Rate:"))

        let slider = NSSlider(value: 10, minValue: 5, maxValue: 20, target: self, action: #selector(rateChanged(_:)))
        slider.numberOfTickMarks = 4
        slider.allowsTickMarkValuesOnly = true
        slider.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rateSlider = slider
        rateRow.addArrangedSubview(slider)
        rateStack.addArrangedSubview(rateRow)

        let labelsRow = NSStackView()
        labelsRow.orientation = .horizontal
        labelsRow.distribution = .equalCentering
        labelsRow.addArrangedSubview(NSTextField(labelWithString: "Slow"))
        labelsRow.addArrangedSubview(NSTextField(labelWithString: "Normal"))
        labelsRow.addArrangedSubview(NSTextField(labelWithString: "Fast"))
        rateStack.addArrangedSubview(labelsRow)

        box.addSubview(rateStack)
        NSLayoutConstraint.activate([
            rateStack.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 12),
            rateStack.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -12),
            rateStack.topAnchor.constraint(equalTo: box.topAnchor, constant: 18),
            rateStack.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -12),
            rateRow.widthAnchor.constraint(greaterThanOrEqualToConstant: 260)
        ])
        stack.addArrangedSubview(box)

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            voiceRow.widthAnchor.constraint(equalTo: stack.widthAnchor),
            popup.widthAnchor.constraint(greaterThanOrEqualToConstant: 260),
            box.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])
    }

    private func populateVoiceMenu() {
        guard let popup = voicePopup else { return }
        ensureDefaultVoiceSaved()
        let names = AppContext.shared.speakerMan.voiceNames()
        popup.removeAllItems()
        if names.isEmpty {
            popup.addItem(withTitle: "No English voices available")
            popup.isEnabled = false
            return
        }
        popup.addItems(withTitles: names)
        let savedVoice = AppContext.shared.prefs.continuousSpeechVoice
        if !savedVoice.isEmpty, let index = names.firstIndex(of: savedVoice) {
            popup.selectItem(at: index)
        } else {
            popup.selectItem(at: 0)
        }
    }

    private func ensureDefaultVoiceSaved() {
        guard let store else { return }
        let names = AppContext.shared.speakerMan.voiceNames()
        guard let firstVoice = names.first else { return }
        let saved = store.state.prefs.continuousSpeechVoice
        if saved.isEmpty || !names.contains(saved) {
            store.dispatch(SetContinuousSpeechVoiceAction(firstVoice))
        }
    }

    private func syncControlsFromStore() {
        guard let store else { return }
        let prefs = store.state.prefs
        continuousSpeechCheckbox?.state = prefs.continuousSpeechEnabled ? .on : .off
        rateSlider?.integerValue = prefs.continuousSpeechRate
        populateVoiceMenu()
        syncControlEnabledState()
    }

    private func syncControlEnabledState() {
        let speechEnabled = store?.state.prefs.continuousSpeechEnabled ?? false
        let hasSpeech = AppContext.hasContinuousSpeech()
        let controlsEnabled = hasSpeech && speechEnabled
        voicePopup?.isEnabled = hasSpeech
        speakerButton?.isEnabled = controlsEnabled
        rateSlider?.isEnabled = controlsEnabled
    }
}

private extension NSImage {
    convenience init?(speakerSymbolName name: String, accessibilityDescription: String) {
        if #available(macOS 11.0, *) {
            self.init(systemSymbolName: name, accessibilityDescription: accessibilityDescription)
        } else {
            self.init(named: NSImage.touchBarAudioOutputVolumeHighTemplateName)
        }
    }
}
