package com.iexceed.apz_text_to_speech

import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.Locale
import java.util.concurrent.ConcurrentLinkedQueue

/** ApzTextToSpeech */
class ApzTextToSpeech : FlutterPlugin, MethodCallHandler, TextToSpeech.OnInitListener {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var tts: TextToSpeech? = null
    private var isTtsInitialized = false
    private var lastSpokenText: String? = null
    private var lastSpokenIndex: Int = 0
    private var isPaused: Boolean = false

    // Queue for pending calls before init
    private val callQueue: ConcurrentLinkedQueue<Pair<MethodCall, Result>> =
        ConcurrentLinkedQueue()

    // Speech configuration
    private var speechBundle: Bundle? = null
    private var currentVolume: Float = 1.0f
    private var currentPitch: Float = 1.0f
    private var currentRate: Float = 1.0f

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "apz_text_to_speech")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
        
        // Initialize TTS immediately
        tts = TextToSpeech(context, this)
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            isTtsInitialized = true
            Log.d("TTSPlugin", "TTS initialized successfully")

            val mainHandler = Handler(Looper.getMainLooper())

            // Attach progress listener
            tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                override fun onStart(utteranceId: String?) {
                    mainHandler.post {
                        channel.invokeMethod("onStart", null)
                    }
                }

                override fun onDone(utteranceId: String?) {
                    mainHandler.post {
                        lastSpokenIndex = 0 // Reset index when done
                        channel.invokeMethod("onCompletion", null)
                    }
                }

                override fun onError(utteranceId: String?) {
                    mainHandler.post {
                        channel.invokeMethod("onError", "TTS error: $utteranceId")
                    }
                }
                
                // This is the key method for tracking progress
                override fun onRangeStart(utteranceId: String?, start: Int, end: Int, frame: Int) {
                    lastSpokenIndex = start
                    Log.d("TTSPlugin", "Speaking from index: $lastSpokenIndex")
                }

                override fun onStop(utteranceId: String?, interrupted: Boolean) {
                    if (interrupted) {
                        mainHandler.post {
                            channel.invokeMethod("onStop", null)
                        }
                    }
                }
            })

            // Process queued calls
            while (callQueue.isNotEmpty()) {
                val (call, result) = callQueue.poll()
                handleMethodCall(call, result)
            }
        } else {
            isTtsInitialized = false
            Log.e("TTSPlugin", "Failed to initialize TTS engine")
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (!isTtsInitialized) {
            // Queue calls until init is done
            callQueue.add(call to result)
            Log.d("TTSPlugin", "TTS not ready yet → Queued method: ${call.method}")
            return
        }
        handleMethodCall(call, result)
    }

    private fun handleMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "speak" -> {
                val text = call.argument<String>("text")
                if (text != null) {
                    lastSpokenText = text
                    lastSpokenIndex = 0 // Reset index for new speech
                    isPaused = false
                    speakText(text, result)
                } else result.error("INVALID_ARGUMENT", "Text cannot be null", null)
            }

            "stop" -> {
                tts?.stop()
                lastSpokenIndex = 0 // Reset index on full stop
                isPaused = false
                result.success(true)
            }

            "pause" -> {
                if (tts?.isSpeaking == true) {
                    tts?.stop() // simulate pause
                    isPaused = true
                    result.success(true)
                } else {
                    result.success(false) // Not speaking, so can't pause
                }
            }

            "resume" -> {
                if (isPaused && lastSpokenText != null && lastSpokenIndex < lastSpokenText!!.length) {
                    val remainingText = lastSpokenText!!.substring(lastSpokenIndex)
                    isPaused = false
                    speakText(remainingText, result)
                } else {
                    result.success(false) // Nothing to resume or not in paused state
                }
            }

            "getVoices" -> {
                val voices = tts?.voices
                if (voices != null) {
                    val voiceList = voices.map {
                        mapOf("name" to it.name, "locale" to it.locale.toLanguageTag())
                    }
                    result.success(voiceList)
                } else result.success(emptyList<Map<String, String>>())
            }

            "setVoice" -> {
                val name = call.argument<String>("voiceName")
                val locale = call.argument<String>("locale")
                val voice = tts?.voices?.find { it.name == name && it.locale.toLanguageTag() == locale }
                if (voice != null) {
                    tts?.voice = voice
                    Log.d("TTSPlugin1-Voice", "$voice")
                    result.success(true)
                } else {
                    Log.d("TTSPlugin1-Voice", "VOICE_NOT_FOUND")
                    result.error("VOICE_NOT_FOUND", "Voice not found", null)
                }
            }

            "setSpeechRate" -> {
                val rate = call.argument<Double>("rate")?.toFloat()
                if (rate != null) {
                    if(rate in 0.1f..0.5f){
                        currentRate = rate * 2.0f
                        tts?.setSpeechRate(currentRate)
                        Log.d("TTSPlugin1", "Adjusted rate to $currentRate for input $rate")
                        result.success(true)
                    }
                    else if(rate in 0.5f..2.0f){
                        currentRate = rate
                        tts?.setSpeechRate(currentRate)
                        Log.d("TTSPlugin2", "Adjusted rate to $currentRate for input $rate")
                        result.success(true)
                    }
                    else{
                        Log.d("TTSPlugin", "Invalid rate $rate value - Range is 0.1 to 2.0")
                        result.success(false)
                        return
                    }
                } else {
                    Log.d("TTSPlugin", "Invalid rate $rate value - Range is 0.1 to 2.0")
                    result.success(false)
                }
            }

            "setPitch" -> {
                val pitch = call.argument<Double>("pitch")?.toFloat()
                if (pitch != null && pitch in 0.5f..2.0f) {
                    currentPitch = pitch
                    tts?.setPitch(currentPitch)
                    result.success(true)
                } else {
                    Log.d("TTSPlugin", "Invalid pitch $pitch value - Range is from 0.5 to 2.0")
                    result.success(false)
                }
            }

            "setVolume" -> {
                val vol = call.argument<Double>("volume")?.toFloat()
                if (vol != null && vol in 0.0f..1.0f) {
                    currentVolume = vol
                    if (speechBundle == null) {
                        speechBundle = Bundle()
                    }
                    speechBundle!!.putFloat(TextToSpeech.Engine.KEY_PARAM_VOLUME, currentVolume)
                    Log.d("TTSPlugin", "Volume set to $currentVolume")
                    result.success(true)
                } else {
                    Log.d("TTSPlugin", "Invalid volume $vol value - Range is from 0.0 to 1.0")
                    result.success(false)
                }
            }

            else -> result.notImplemented()
        }
    }

    private fun speakText(text: String, result: Result) {
        if (speechBundle == null) {
            speechBundle = Bundle()
            speechBundle!!.putFloat(TextToSpeech.Engine.KEY_PARAM_VOLUME, currentVolume)
        }
        val params = speechBundle ?: Bundle()
        params.putString(TextToSpeech.Engine.KEY_PARAM_UTTERANCE_ID, "uttId")

        val res = tts?.speak(text, TextToSpeech.QUEUE_FLUSH, params, "uttId")
        result.success(res)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        tts?.shutdown()
        tts = null
    }
}