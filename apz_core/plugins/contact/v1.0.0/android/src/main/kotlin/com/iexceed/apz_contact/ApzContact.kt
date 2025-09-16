package com.iexceed.apz_contact

import android.content.ContentResolver
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.provider.ContactsContract
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/** * ApzContactsFetcher
 * with Background Thread
 */

class ApzContact : FlutterPlugin, MethodCallHandler {

  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  // Coroutine scope for plugin
  private val job = Job()
  private val coroutineScope = CoroutineScope(Dispatchers.Main + job)

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.iexceed/contacts_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "getContacts" -> {
        val fetchEmail = call.argument<Boolean>("fetchEmail") ?: false
        val fetchPhoto = call.argument<Boolean>("fetchPhoto") ?: false
        val searchQuery = call.argument<String>("searchQuery") ?: ""

        // Run getContacts on IO dispatcher (background thread)
        coroutineScope.launch {
          try {
            val contacts = withContext(Dispatchers.IO) {
              getContacts(fetchEmail, fetchPhoto, searchQuery)
            }
            result.success(contacts)
          } catch (e: Exception) {
            result.error("ERROR", "Failed to get contacts: ${e.localizedMessage}", null)
          }
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    job.cancel()  // Cancel all coroutines when plugin detached
  }

  /// This function fetches list of email and numbers and bytes conversion.
  private fun getContacts(
    fetchEmail: Boolean = false,
    fetchPhoto: Boolean = false,
    searchQuery: String? = null
  ): List<Map<String, Any>> {
    val contactList = mutableListOf<Map<String, Any>>()
    val resolver: ContentResolver = context.contentResolver

    var selection: String? = null
    var selectionArgs: Array<String>? = null

    if (!searchQuery.isNullOrBlank()) {
      selection = "${ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME} LIKE ? OR " +
              "${ContactsContract.CommonDataKinds.Phone.NUMBER} LIKE ?"
      selectionArgs = arrayOf("%$searchQuery%", "%$searchQuery%")
    }

    val cursor: Cursor? = resolver.query(
      ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
      null,
      selection,
      selectionArgs,
      null
    )

    // Group by name (case-insensitive)
    val contactMap = mutableMapOf<String, MutableMap<String, Any>>()

    cursor?.use {
      val nameIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
      val numberIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
      val photoUriIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.PHOTO_THUMBNAIL_URI)

      while (it.moveToNext()) {
        val nameRaw = it.getString(nameIndex) ?: ""
        val name = nameRaw.trim()
        if (name.isEmpty()) continue // skip empty names

        val number = it.getString(numberIndex) ?: ""

        val key = name.lowercase() // case-insensitive grouping by name

        val contact = contactMap.getOrPut(key) {
          mutableMapOf(
            "name" to name,
            "numbers" to mutableSetOf<String>(),  // use Set to avoid duplicates
            "emails" to mutableSetOf<String>(),
            "photoBytes" to ByteArray(0)
          )
        }

        if (number.isNotBlank()) {
          (contact["numbers"] as MutableSet<String>).add(number)
        }

        if (fetchPhoto && (contact["photoBytes"] as ByteArray).isEmpty()) {
          val photoUriString = it.getString(photoUriIndex)
          val photoBytes = photoUriString?.let { uriStr ->
            try {
              val uri = Uri.parse(uriStr)
              resolver.openInputStream(uri)?.use { stream -> stream.readBytes() }
            } catch (e: Exception) {
              null
            }
          }
          if (photoBytes != null) {
            contact["photoBytes"] = photoBytes
          }
        }
      }
    }

    /// Add firstName and lastName by querying StructuredName
    val structuredCursor = resolver.query(
      ContactsContract.Data.CONTENT_URI,
      arrayOf(
        ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME,
        ContactsContract.CommonDataKinds.StructuredName.GIVEN_NAME,
        ContactsContract.CommonDataKinds.StructuredName.FAMILY_NAME
      ),
      "${ContactsContract.Data.MIMETYPE} = ?",
      arrayOf(ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE),
      null
    )

    structuredCursor?.use { sc ->
      val displayNameIndex = sc.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME)
      val firstNameIndex = sc.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName.GIVEN_NAME)
      val lastNameIndex = sc.getColumnIndex(ContactsContract.CommonDataKinds.StructuredName.FAMILY_NAME)

      while (sc.moveToNext()) {
        val displayName = sc.getString(displayNameIndex)?.trim() ?: continue
        val firstName = sc.getString(firstNameIndex)?.trim() ?: ""
        val lastName = sc.getString(lastNameIndex)?.trim() ?: ""
        val key = displayName.lowercase()

        val contact = contactMap[key]
        if (contact != null) {
          contact["firstName"] = firstName
          contact["lastName"] = lastName
        }
      }
    }



    if (fetchEmail) {
      val contactIdToName = mutableMapOf<String, String>()
      val phoneCursor = resolver.query(
        ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
        arrayOf(
          ContactsContract.CommonDataKinds.Phone.CONTACT_ID,
          ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME
        ),
        null,
        null,
        null
      )
      phoneCursor?.use { pc ->
        val contactIdIndex = pc.getColumnIndex(ContactsContract.CommonDataKinds.Phone.CONTACT_ID)
        val nameIndex = pc.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
        while (pc.moveToNext()) {
          val contactId = pc.getString(contactIdIndex) ?: continue
          val nameRaw = pc.getString(nameIndex) ?: continue
          val name = nameRaw.trim()
          if (name.isNotEmpty()) {
            contactIdToName[contactId] = name
          }
        }
      }

      val emailCursor2 = resolver.query(
        ContactsContract.CommonDataKinds.Email.CONTENT_URI,
        null,
        null,
        null,
        null
      )

      emailCursor2?.use { ec ->
        val contactIdIndex = ec.getColumnIndex(ContactsContract.CommonDataKinds.Email.CONTACT_ID)
        val emailIndex = ec.getColumnIndex(ContactsContract.CommonDataKinds.Email.ADDRESS)

        while (ec.moveToNext()) {
          val contactId = ec.getString(contactIdIndex) ?: continue
          val email = ec.getString(emailIndex)?.trim() ?: continue
          if (email.isEmpty()) continue

          val name = contactIdToName[contactId]?.trim() ?: continue
          val key = name.lowercase()
          val contact = contactMap.getOrPut(key) {
            mutableMapOf(
              "name" to name,
              "numbers" to mutableSetOf<String>(),
              "emails" to mutableSetOf<String>(),
              "photoBytes" to ByteArray(0)
            )
          }
          (contact["emails"] as MutableSet<String>).add(email)
        }
      }
    }

    // Convert sets to lists before returning, and **filter contacts by searchQuery match in any field**
    contactMap.values.forEach { contact ->
      val numbersSet = contact["numbers"] as MutableSet<String>
      val emailsSet = contact["emails"] as MutableSet<String>

      val numbers = numbersSet.toList()
      val emails = emailsSet.toList()

      val name = (contact["name"] as String).lowercase()
      val search = searchQuery?.lowercase()?.trim()

      // Filter contacts: if searchQuery is not null/empty, contact must match in name, numbers, or emails
      val matchesSearch = if (!search.isNullOrEmpty()) {
        name.contains(search) ||
                numbers.any { it.lowercase().contains(search) } ||
                emails.any { it.lowercase().contains(search) }
      } else {
        true // no search query = include all contacts
      }

      if (matchesSearch && (numbers.isNotEmpty() || emails.isNotEmpty())) {
        contact["numbers"] = numbers
        contact["emails"] = emails
        contactList.add(contact)

      }
    }

    return contactList
  }




}
