package com.iexceed.apz_contact_picker

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.provider.ContactsContract
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

import java.io.ByteArrayOutputStream

/** ApzContactPicker */
class ApzContactPicker: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {

  private lateinit var channel : MethodChannel
  private var currentActivity: Activity? = null
  private var pendingResult: Result? = null
  private val PICK_CONTACT_REQUEST = 1

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "contact_picker_plugin")
    channel.setMethodCallHandler(this)
  }

  /// This method is called when Dart invokes a method on the MethodChannel.
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "pickContact") {
      this.pendingResult = result
      // Directly launch the contact picker.
      // Permission check is now assumed to be handled on the Dart side before this call.
      launchContactPicker()
    } else {
      result.notImplemented()
    }
  }

  /// This method launches the Android system's contact picker UI.
  private fun launchContactPicker() {
    if (currentActivity == null) {
      pendingResult?.error("ACTIVITY_NOT_ATTACHED", "Plugin not attached to an activity.", null)
      pendingResult = null
      return
    }

    val intent = Intent(Intent.ACTION_PICK, ContactsContract.Contacts.CONTENT_URI)
    try {
      currentActivity?.startActivityForResult(intent, PICK_CONTACT_REQUEST)
    } catch (e: Exception) {
      pendingResult?.error("ACTIVITY_NOT_FOUND", "Could not launch contact picker: ${e.message}", null)
      pendingResult = null
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  // --- ActivityAware methods ---
  // These methods manage the plugin's lifecycle in relation to the Android Activity.
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    currentActivity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    currentActivity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    currentActivity = binding.activity
    binding.addActivityResultListener(this)
  }

  override fun onDetachedFromActivity() {
    currentActivity = null
  }

  // --- ActivityResultListener (for contact picker result) ---
  /// This method receives the result from an activity launched using startActivityForResult (e.g., the native contact picker).
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode == PICK_CONTACT_REQUEST) {
      if (pendingResult == null) {
        return false
      }

      if (resultCode == Activity.RESULT_OK) { // User successfully selected a contact
        val contactUri: Uri? = data?.data
        if (contactUri != null) {
          queryContactDetails(contactUri) // Proceed to extract details from the selected contact URI
        } else {
          pendingResult?.success(null) // User picked nothing/canceled somehow
          pendingResult = null
        }
      } else if (resultCode == Activity.RESULT_CANCELED) { // User canceled the picker
        pendingResult?.success(null) // Send null back to Dart to indicate cancellation.
        pendingResult = null
      } else { // Some other error occurred during picking.
        pendingResult?.error("PICK_FAILED", "Contact picker failed with result code: $resultCode", null)
        pendingResult = null
      }
      return true
    }
    return false
  }

  /// This method queries the contact details (name, phone, email, thumbnail) from the given contact URI and sends them back to Dart as a map.
  private fun queryContactDetails(contactUri: Uri) {
    val result: MutableMap<String, Any?> = mutableMapOf()
    var cursor: Cursor? = null
    try {
      // Get contact ID
      cursor = currentActivity?.contentResolver?.query(contactUri, arrayOf(ContactsContract.Contacts._ID), null, null, null)
      cursor?.moveToFirst()
      val contactId = cursor?.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts._ID))

      if (contactId != null) {
        // Full Name
        val displayNameCursor = currentActivity?.contentResolver?.query(
          ContactsContract.Data.CONTENT_URI,
          arrayOf(ContactsContract.Data.DISPLAY_NAME),
          "${ContactsContract.Data.CONTACT_ID} = ? AND ${ContactsContract.Data.MIMETYPE} = ?",
          arrayOf(contactId, ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE),
          null
        )
        displayNameCursor?.use {
          if (it.moveToFirst()) {
            result["fullName"] = it.getString(it.getColumnIndexOrThrow(ContactsContract.Data.DISPLAY_NAME))
          }
        }

        // Phone Number
        val phoneCursor = currentActivity?.contentResolver?.query(
          ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
          arrayOf(ContactsContract.CommonDataKinds.Phone.NUMBER, ContactsContract.CommonDataKinds.Phone.TYPE),
          "${ContactsContract.CommonDataKinds.Phone.CONTACT_ID} = ?",
          arrayOf(contactId),
          null
        )
        phoneCursor?.use {
          if (it.moveToFirst()) { // Get the first phone number as primary
            result["phoneNumber"] = it.getString(it.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Phone.NUMBER))
          }
        }

        // Email (Optional)
        val emailCursor = currentActivity?.contentResolver?.query(
          ContactsContract.CommonDataKinds.Email.CONTENT_URI,
          arrayOf(ContactsContract.CommonDataKinds.Email.ADDRESS),
          "${ContactsContract.CommonDataKinds.Email.CONTACT_ID} = ?",
          arrayOf(contactId),
          null
        )
        emailCursor?.use {
          if (it.moveToFirst()) { // Get the first email as primary
            result["email"] = it.getString(it.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Email.ADDRESS))
          }
        }

        // --- FIX START ---
        // Thumbnail Image - Robust handling for missing images
        var thumbnailBytes: ByteArray? = null
        try {
            currentActivity?.contentResolver?.openAssetFileDescriptor(Uri.withAppendedPath(contactUri, ContactsContract.Contacts.Photo.CONTENT_DIRECTORY), "r")?.use { photoData ->
                val bitmap = BitmapFactory.decodeFileDescriptor(photoData.fileDescriptor)
                if (bitmap != null) {
                    val stream = ByteArrayOutputStream()
                    // Using JPEG for smaller size, 80% quality. Change to PNG if transparency is required.
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 80, stream)
                    thumbnailBytes = stream.toByteArray()
                    stream.close()
                }
            }
        } catch (e: Exception) {
            // Log the error but continue execution without a thumbnail.
            // Replace with Android's Log.e for production use:
            // android.util.Log.e("ApzContactPicker", "Error loading contact thumbnail: ${e.message}", e)
            println("ApzContactPicker: Error loading contact thumbnail: ${e.message}")
            thumbnailBytes = null // Ensure it's null on error
        }
        result["thumbnail"] = thumbnailBytes
        // --- FIX END ---
      }

      pendingResult?.success(result)
    } catch (e: Exception) {
      pendingResult?.error("CONTACT_DETAILS_ERROR", "Error retrieving contact details: ${e.message}", null)
    } finally {
      cursor?.close()
      pendingResult = null // Clear pending result after completion
    }
  }
}