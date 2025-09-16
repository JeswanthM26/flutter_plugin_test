@file:OptIn(ExperimentalMaterial3Api::class)

package com.iexceed.apz_datepicker
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.ViewCompositionStrategy
import androidx.fragment.app.DialogFragment
import java.time.Instant 
import java.time.ZoneId
import androidx.compose.foundation.layout.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.layout.*
import androidx.compose.ui.graphics.Color
import java.util.Locale


// Define a companion object to create an instance with arguments
// This is the standard way to pass data to a Fragment
class ComposeDatePickerDialogFragment : DialogFragment() {

    override fun getTheme(): Int = R.style.TransparentDialogTheme

    // Define keys for arguments
    companion object {
        const val KEY_INITIAL_MILLIS = "initialMillis"
        const val KEY_MIN_MILLIS = "minMillis"
        const val KEY_MAX_MILLIS = "maxMillis"
        const val KEY_CANCEL_TEXT = "cancelText"
        const val KEY_DONE_TEXT = "doneText"
        const val KEY_SELECTED_DATE_COLOR = "primaryColor"
        const val KEY_BUTTON_TEXT_COLOR = "errorColor"
        const val KEY_DATE_FORMAT = "dateFormat"
        const val KEY_LANGUAGE_CODE = "languageCode"

        // Use a static factory method to create instances and set arguments
        fun newInstance(
            initialMillis: Long,
            minMillis: Long?,
            maxMillis: Long?,
            cancelText: String?,
            doneText: String?,
            primaryColor: Long?, 
            errorColor: Long?,
            dateFormat: String?,
            languageCode: String

        ): ComposeDatePickerDialogFragment {
            return ComposeDatePickerDialogFragment().apply {
                arguments = Bundle().apply {
                    putLong(KEY_INITIAL_MILLIS, initialMillis)
                    minMillis?.let { putLong(KEY_MIN_MILLIS, it) }
                    maxMillis?.let { putLong(KEY_MAX_MILLIS, it) }
                    putString(KEY_CANCEL_TEXT, cancelText)
                    putString(KEY_DONE_TEXT, doneText)
                    primaryColor?.let { putLong(KEY_SELECTED_DATE_COLOR, it) }
                    errorColor?.let { putLong(KEY_BUTTON_TEXT_COLOR, it) }
                    putString(KEY_DATE_FORMAT, dateFormat)
                    putString(KEY_LANGUAGE_CODE, languageCode)

                }
            }
        }
    }

    // Callbacks to communicate back to the Flutter side or activity
    var onDateSelected: ((Long) -> Unit)? = null
    var onDismiss: (() -> Unit)? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        isCancelable = false
    }
    
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        val languageCode = arguments?.getString(KEY_LANGUAGE_CODE) ?: "en"
        val locale = Locale(languageCode)
        Locale.setDefault(locale)

        val config = resources.configuration
        config.setLocale(locale)
        val localizedContext = requireContext().createConfigurationContext(config)
        return ComposeView(localizedContext).apply {
            // This strategy tells Compose to dispose of the composition when the
            // Fragment's view hierarchy is destroyed, which is the default for Fragments.
            setViewCompositionStrategy(ViewCompositionStrategy.DisposeOnViewTreeLifecycleDestroyed)
            setContent {
                val initialMillis = arguments?.getLong(KEY_INITIAL_MILLIS) ?: System.currentTimeMillis()
                val minMillis = arguments?.getLong(KEY_MIN_MILLIS)
                val maxMillis = arguments?.getLong(KEY_MAX_MILLIS)
                val cancelText = arguments?.getString(KEY_CANCEL_TEXT) ?: "Cancel"
                val doneText = arguments?.getString(KEY_DONE_TEXT) ?: "OK"
                val primaryColor = arguments?.getLong(KEY_SELECTED_DATE_COLOR)?.let { Color(it) } ?: Color(0xFF008577)
                val errorColor = arguments?.getLong(KEY_BUTTON_TEXT_COLOR)?.let { Color(it) } ?: Color(0xFF6200EE)
                val dateFormat = arguments?.getString(KEY_DATE_FORMAT) ?: "yyyy-MM-dd"

                MaterialTheme(
                    colorScheme = MaterialTheme.colorScheme.copy(
                    primary = primaryColor,
                 )
                 ) {
                    DatePickerContent(
                        initialMillis = initialMillis,
                        minMillis = minMillis,
                        maxMillis = maxMillis,
                        cancelText = cancelText,
                        doneText = doneText,
                        cancelTextColor = errorColor,
                        doneTextColor = primaryColor,
                        onDateSelected = { selectedDate ->
                            // Dismiss the dialog fragment
                            dismiss()
                            onDateSelected?.invoke(selectedDate)
                        },
                        onDismiss = {
                            // Dismiss the dialog fragment
                            dismiss()
                            onDismiss?.invoke()
                        }
                    )
                }
            }
        }
    }
}

// Your DatePickerContent Composable remains the same
@Composable
fun DatePickerContent(
    initialMillis: Long,
    minMillis: Long?,
    maxMillis: Long?,
    cancelText: String,
    doneText: String,
    cancelTextColor: Color,
    doneTextColor: Color,
    onDateSelected: (Long) -> Unit,
    onDismiss: () -> Unit
) {
    val initialYear = Instant.ofEpochMilli(initialMillis)
        .atZone(ZoneId.systemDefault())
        .year

    val minYear = minMillis?.let {
        Instant.ofEpochMilli(it).atZone(ZoneId.systemDefault()).year
    } ?: (initialYear - 10)

    val maxYear = maxMillis?.let {
        Instant.ofEpochMilli(it).atZone(ZoneId.systemDefault()).year
    } ?: (initialYear + 10)

    val state = rememberDatePickerState(
        initialSelectedDateMillis = initialMillis,
        yearRange = minYear..maxYear
    )
        Surface(
            shape = MaterialTheme.shapes.medium,
            tonalElevation = 6.dp,
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
            ) {
                DatePicker(
                    state = state,
                    showModeToggle = false,
                    modifier = Modifier.fillMaxWidth()   
                )
                Spacer(modifier = Modifier.height(16.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.End
                ) {
                    TextButton(onClick = onDismiss) {
                        Text(cancelText, color = cancelTextColor)
                    }
                    TextButton(onClick = {
                        state.selectedDateMillis?.let { onDateSelected(it) }
                    }) {
                        Text(doneText, color = doneTextColor)
                    }
                }
            }
        }
}