package com.iexceed.apz_play_integrity

import android.content.Context
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenProvider
import com.google.android.play.core.integrity.StandardIntegrityManager.StandardIntegrityTokenRequest
import com.google.android.play.core.integrity.StandardIntegrityManager.PrepareIntegrityTokenRequest
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class StandardIntegrityHandler(private val context: Context) {

    private val standardIntegrityManager: StandardIntegrityManager = IntegrityManagerFactory.createStandard(context)
    private var integrityTokenProvider: StandardIntegrityTokenProvider? = null;

    fun prepareStandardIntegrityToken(call: MethodCall, result: MethodChannel.Result) {

        val cloudProjectNumberStr = call.argument<String>("cloudProjectNumber")

        val cloudProjectNumber = cloudProjectNumberStr?.toLongOrNull()
        if (cloudProjectNumber == null) {
            result.error("INVALID_CLOUD_PROJECT_NUMBER", "CloudProjectNumber must be a valid number", null)
            return
        }

        standardIntegrityManager.prepareIntegrityToken(
            PrepareIntegrityTokenRequest.builder()
                .setCloudProjectNumber(cloudProjectNumber)
                .build()
        )
        .addOnSuccessListener { tokenProvider ->
            integrityTokenProvider = tokenProvider
            result.success(true)
        }
        .addOnFailureListener { e ->
            result.error("STANDARD_PLAY_INTEGRITY_ERROR", "Preparation failed: ${e.message}", null)
        }
    }

    fun requestStandardIntegrityToken(call: MethodCall, result: MethodChannel.Result) {
        if (integrityTokenProvider == null) {
            result.error("TOKEN_PROVIDER_NOT_INITIALISED", "Token provider is not intialised. Call 'prepareStandardIntegrityToken' method to intialise token provider.", null)
        } else {
            val requestHash = call.argument<String>("requestHash")

            integrityTokenProvider!!.request(
                StandardIntegrityTokenRequest.builder()
                    .setRequestHash(requestHash)
                    .build()
            )
            .addOnSuccessListener { tokenResponse ->
                result.success(tokenResponse.token())
            }
            .addOnFailureListener { e ->
                result.error("STANDARD_PLAY_INTEGRITY_ERROR", "Token request failed: ${e.message}", null)
            }
        }
    }

}