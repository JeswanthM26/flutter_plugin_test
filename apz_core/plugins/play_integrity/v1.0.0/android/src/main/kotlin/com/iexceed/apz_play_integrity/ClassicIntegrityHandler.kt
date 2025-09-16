package com.iexceed.apz_play_integrity

import android.content.Context
import com.google.android.play.core.integrity.IntegrityManager
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
class ClassicIntegrityHandler(private val context: Context) {

    private val classicIntegrityManager: IntegrityManager = IntegrityManagerFactory.create(context)

    fun requestClassicIntegrityToken(call: MethodCall, result: MethodChannel.Result) {
        val nonce = call.argument<String>("nonce")
        val cloudProjectNumberStr = call.argument<String>("cloudProjectNumber")

        val cloudProjectNumber = cloudProjectNumberStr?.toLongOrNull()
        if (cloudProjectNumber == null) {
            result.error("INVALID_CLOUD_PROJECT_NUMBER", "CloudProjectNumber must be a valid number", null)
            return
        }

        print(nonce)

        val request = IntegrityTokenRequest.builder()
            .setNonce(nonce)
            .setCloudProjectNumber(cloudProjectNumber)
            .build()

        classicIntegrityManager.requestIntegrityToken(request)
            .addOnSuccessListener { response ->
                result.success(response.token())
            }
            .addOnFailureListener { e ->
                result.error("CLASSIC_PLAY_INTEGRITY_ERROR", e.message, null)
            }
    }
}