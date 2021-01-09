//
//  SpeakerMan.swift
//  Savitar2
//
//  Created by Jay Koutavas on 8/16/20.
//  Copyright © 2020 Heynow Software. All rights reserved.
//

import AVFoundation
import Cocoa

class SpeakerMan {
    // https://stackoverflow.com/a/38445571/246887
    func soundNames() -> [String] {
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

    func playAudio(trigger: Trigger, muteSound: Bool = false, muteSpeaking: Bool = false) {
        if !muteSound && trigger.audioType == .sound, let soundName = trigger.sound {
            NSSound(named: NSSound.Name(soundName))?.play()
        } else if !muteSpeaking {
            guard let voiceName = trigger.voice else { return }
            var say: String?
            if trigger.audioType == .sayText {
                say = trigger.say
            } else if trigger.audioType == .speakEvent {
                say = trigger.matchedText.count > 0 ? trigger.matchedText : trigger.name
            }
            guard let text = say else { return }
            speak(text: text, voiceName: voiceName)
        }
    }

    func voiceNames() -> [String] {
        // Override this
        return []
    }

    func speak(text _: String, voiceName _: String) {
        // Override this
    }

    func flushSpeech() {
        // Override this
    }
}

class SpeakerManNS: SpeakerMan {
    var speechSynth = NSSpeechSynthesizer()
    var voices: [NSSpeechSynthesizer.VoiceName] { NSSpeechSynthesizer.availableVoices }

    override func voiceNames() -> [String] {
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

    override func speak(text: String, voiceName: String) {
        speechSynth.stopSpeaking()
        speechSynth.setVoice(identifierForVoiceName(voiceName))
        // rate here is words per minute and it varies by voice
        speechSynth.rate *= (Float)(AppContext.shared.prefs.continuousSpeechRate) / 10.0
        speechSynth.startSpeaking(text)
    }

    override func flushSpeech() {
        speechSynth.stopSpeaking()
        speechSynth = NSSpeechSynthesizer()
    }
}

class SpeakerManAV: SpeakerMan {
    var speechSynth = AVSpeechSynthesizer()
    var voices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("en-") }
    }

    override func voiceNames() -> [String] {
        var names: [String] = []
        for voice in voices {
            let parts = voice.identifier.components(separatedBy: ".")
            if let name = parts.last {
                names.append(name)
            }
        }
        return names
    }

    override func speak(text: String, voiceName: String) {
        let utterance = AVSpeechUtterance(string: text)
        for voice in voices {
            if voice.identifier.hasSuffix(voiceName) {
                utterance.voice = AVSpeechSynthesisVoice(identifier: voice.identifier)
                // rate here is a percentage (0.0..1.0)
                var adjustedRate = AVSpeechUtteranceDefaultSpeechRate *
                    (Float(AppContext.shared.prefs.continuousSpeechRate - 5) / 10.0)
                if adjustedRate < AVSpeechUtteranceMinimumSpeechRate {
                    adjustedRate = AVSpeechUtteranceMinimumSpeechRate
                } else if adjustedRate > AVSpeechUtteranceMaximumSpeechRate {
                    adjustedRate = AVSpeechUtteranceMaximumSpeechRate
                }
                utterance.rate = adjustedRate
                speechSynth.speak(utterance)
                break
            }
        }
    }

    override func flushSpeech() {
        speechSynth.stopSpeaking(at: .word)
        speechSynth = AVSpeechSynthesizer()
    }
}
