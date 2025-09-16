import Flutter
import UIKit
import AVFoundation

public class ApzTextToSpeech: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel!
    private var synthesizer = AVSpeechSynthesizer()
    private var lastSpokenText: String?
    private var lastSpokenIndex: Int = 0
    private var isPaused: Bool = false
    private var currentRate: Float = AVSpeechUtteranceDefaultSpeechRate
    private var currentPitch: Float = 1.0
    private var currentVolume: Float = 1.0
    private var currentVoice: AVSpeechSynthesisVoice?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "apz_text_to_speech", binaryMessenger: registrar.messenger())
        let instance = ApzTextToSpeech(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    init(channel: FlutterMethodChannel) {
        super.init()
        self.channel = channel
        synthesizer.delegate = self
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "speak":
            if let args = call.arguments as? [String: Any],
               let text = args["text"] as? String {
                lastSpokenText = text
                lastSpokenIndex = 0
                isPaused = false
                speakText(text: text)
                result(true)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Text cannot be null", details: nil))
            }

        case "stop":
            synthesizer.stopSpeaking(at: .immediate)
            lastSpokenIndex = 0
            isPaused = false
            result(true)

        case "pause":
            if synthesizer.isSpeaking {
                synthesizer.pauseSpeaking(at: .immediate)
                isPaused = true
                result(true)
            } else {
                result(false)
            }

        case "resume":
            if isPaused {
                synthesizer.continueSpeaking()
                isPaused = false
                result(true)
            } else {
                result(false)
            }

        case "getVoices":
            let voices = AVSpeechSynthesisVoice.speechVoices().map {
                ["name": $0.name, "locale": $0.language]
            }
            result(voices)

        case "setVoice":
            if let args = call.arguments as? [String: Any],
               let name = args["voiceName"] as? String,
               let locale = args["locale"] as? String
                {
                if let voice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.name == name && $0.language == locale}) {
                    currentVoice = voice
                    result(true)
                } else {
                    result(FlutterError(code: "VOICE_NOT_FOUND", message: "Voice not found", details: nil))
                }
            }

        case "setSpeechRate":
            if let args = call.arguments as? [String: Any],
               let rate = args["rate"] as? Double {
                if rate >= 0.0 && rate <= 1.0 {
                    currentRate = Float(rate)
                    result(true)
                } else {
                    NSLog("Invalid rate \(rate) value - Range is 0.0 to 1.0")
                    result(false)
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Rate null", details: nil))
            }

        case "setPitch":
            if let args = call.arguments as? [String: Any],
               let pitch = args["pitch"] as? Double {
                 if pitch >= 0.5 && pitch <= 2.0 {
                    currentPitch = Float(pitch)
                    result(true)
                } else {
                    NSLog("Invalid pitch \(pitch) value - Range is 0.5 to 2.0")
                    result(false)
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Pitch null", details: nil))
            }

        case "setVolume":
            if let args = call.arguments as? [String: Any],
               let volume = args["volume"] as? Double, volume >= 0.0, volume <= 1.0 {
                currentVolume = Float(volume)
                result(true)
            } else {
                NSLog("Invalid volume value - Range is 0.0 to 1.0")
                result(false)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func speakText(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = currentRate
        utterance.pitchMultiplier = currentPitch
        utterance.volume = currentVolume
        if let voice = currentVoice {
            utterance.voice = voice
        }
        synthesizer.speak(utterance)
    }
}

extension ApzTextToSpeech: AVSpeechSynthesizerDelegate {
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        channel.invokeMethod("onStart", arguments: nil)
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        lastSpokenIndex = 0
        channel.invokeMethod("onCompletion", arguments: nil)
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        channel.invokeMethod("onPause", arguments: nil)
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        channel.invokeMethod("onResume", arguments: nil)
    }

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        channel.invokeMethod("onStop", arguments: nil)
    }
}
