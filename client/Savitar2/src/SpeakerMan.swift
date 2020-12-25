//
//  SpeakerMan.swift
//  Savitar2
//
//  Created by Jay Koutavas on 8/16/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import Cocoa

struct SpeakerMan {
    let speechSynth = NSSpeechSynthesizer()

    // https://stackoverflow.com/a/38445571/246887
    var soundNames: [String] {
        let soundPaths: [String] = ["~/Library/Sounds", "/Library/Sounds", "/Network/Library/Sounds",
                                    "/System/Library/Sounds"]

        var names: [String] = ["Click"] // "Click" is part of the app's resource bundle
        for soundPath in soundPaths {
            let path = soundPath.contains("~") ? soundPath.expandingTildeInPath : soundPath
            let dirEnum = FileManager().enumerator(atPath: path)
            while let file = dirEnum?.nextObject() as? String {
                if !file.contains(".DS_Store") {
                    names.append(file.fileName())
                }
            }
        }
        return names
    }

    var voiceNames: [String] {
        let voices = NSSpeechSynthesizer.availableVoices

        var names: [String] = []
        for voice in voices {
            let attributes = NSSpeechSynthesizer.attributes(forVoice:
                NSSpeechSynthesizer.VoiceName(rawValue: voice.rawValue))
            names.append((attributes[NSSpeechSynthesizer.VoiceAttributeKey.name] as? String)!)
        }
        return names
    }

    private func identifierForVoiceName(_ voiceName: String) -> NSSpeechSynthesizer.VoiceName? {
        for voice in NSSpeechSynthesizer.availableVoices {
            let attributes = NSSpeechSynthesizer.attributes(forVoice:
                NSSpeechSynthesizer.VoiceName(rawValue: voice.rawValue))
            let thisName = (attributes[NSSpeechSynthesizer.VoiceAttributeKey.name] as? String)
            if thisName == voiceName {
                return voice
            }
        }

        return nil
    }

    func playAudio(trigger: Trigger) {
        if trigger.audioType == .sound, let soundName = trigger.sound {
            NSSound(named: NSSound.Name(soundName))?.play()
        } else {
            guard let voiceName = trigger.voice else { return }
            var say: String?
            if trigger.audioType == .sayText {
                say = trigger.say
            } else if trigger.audioType == .speakEvent {
                say = trigger.matchedText.count > 0 ? trigger.matchedText : trigger.name
            }
            speechSynth.stopSpeaking()
            speechSynth.setVoice(identifierForVoiceName(voiceName))
            guard let text = say else { return }
            speechSynth.startSpeaking(text)
        }
    }
}
