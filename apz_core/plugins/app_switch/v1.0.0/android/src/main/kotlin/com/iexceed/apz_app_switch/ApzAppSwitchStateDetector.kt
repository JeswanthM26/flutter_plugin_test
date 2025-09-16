package com.iexceed.apz_app_switch
import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.content.ComponentCallbacks2
import android.content.res.Configuration

// Define a simple callback interface to notify about lifecycle changes.
interface AppLifecycleStateCallback {
    fun onStateChanged(state: AppLifecycleState)
}

// Enum representing the app lifecycle states, mirroring Flutter's AppLifecycleState.
enum class AppLifecycleState {
    resumed,    
    inactive,   
    paused,     
    detached   
}

/**
 * Manages the detection of Android app lifecycle states and notifies a callback.
 *
 * This class uses `Application.ActivityLifecycleCallbacks` to listen to changes
 * in the lifecycle of individual Activities. 
 */
class ApzAppSwitchStateDetector {
    private val TAG = "ApzLifecycles"
    private var resumedActivityCount = 0
    private var startedActivityCount = 0
    private var isAppInBackground = false // Custom flag to track true background state

    private var callback: AppLifecycleStateCallback? = null

    /**
     * Registers the lifecycle callbacks with the application.
     * Call this once, typically when the Flutter engine starts up and an activity is available.
     *
     * @param application The Android Application instance.
     * @param callback The callback interface to receive lifecycle state changes.
     */

      private val appTrimCallback = object : ComponentCallbacks2 {
        override fun onTrimMemory(level: Int) {
           when (level) {
            ComponentCallbacks2.TRIM_MEMORY_UI_HIDDEN -> {
                callback?.onStateChanged(AppLifecycleState.paused)
            }
        }
        }
         override fun onConfigurationChanged(newConfig: Configuration) {
        // No-op
        }
        override fun onLowMemory() {
            // No-op
        }
    }
    
    fun register(application: Application, callback: AppLifecycleStateCallback) {
        this.callback = callback
        application.registerActivityLifecycleCallbacks(activityLifecycleCallbacks)
        application.registerComponentCallbacks(appTrimCallback)
    }

    /**
     * Unregisters the lifecycle callbacks.
     * Call this when the detector is no longer needed (e.g., when the Flutter engine is destroyed).
     *
     * @param application The Android Application instance.
     */
    fun unregister(application: Application) {
        application.unregisterActivityLifecycleCallbacks(activityLifecycleCallbacks)
        application.unregisterComponentCallbacks(appTrimCallback)
        this.callback = null
    }

    /**
     * The ActivityLifecycleCallbacks implementation to track state changes.
     */
    private val activityLifecycleCallbacks = object : Application.ActivityLifecycleCallbacks {
        override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
            // Do Nothing
        }

        override fun onActivityStarted(activity: Activity) {
            startedActivityCount++
            if (isAppInBackground && startedActivityCount == 1) {
                // App is coming from background to foreground (first activity started)
                isAppInBackground = false
                // Emit resumed, as it's the primary state when returning to the foreground.
                callback?.onStateChanged(AppLifecycleState.resumed)
            }
        }

        override fun onActivityResumed(activity: Activity) {
            resumedActivityCount++
            if (resumedActivityCount == 1 && !isAppInBackground) {
                // App has at least one activity resumed, so it's in the foreground.
                // This covers cases like initial launch or resuming from a temporary overlay.
                // Only send 'resumed' if not coming from full background (handled by onActivityStarted)
                callback?.onStateChanged(AppLifecycleState.resumed)
            }
        }

        override fun onActivityPaused(activity: Activity) {
            resumedActivityCount = maxOf(0, resumedActivityCount - 1)
            // If all activities are paused, but some are still started, the app is inactive.
            if (resumedActivityCount == 0 && startedActivityCount > 0) {
                callback?.onStateChanged(AppLifecycleState.inactive)
            }
        }

        override fun onActivityStopped(activity: Activity) {
                startedActivityCount = maxOf(0, startedActivityCount - 1)
            if (startedActivityCount == 0) {
                // All activities are stopped, app has moved to the background.
                isAppInBackground = true
                callback?.onStateChanged(AppLifecycleState.paused)
            }
        }

        override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
            // Not directly relevant for app lifecycle state changes.
        }

        override fun onActivityDestroyed(activity: Activity) {
            if (resumedActivityCount > 0) resumedActivityCount--
            if (startedActivityCount > 0) startedActivityCount--
            if (resumedActivityCount == 0 && startedActivityCount == 0) {
                // If all activities are destroyed, we can consider the app detached (like Flutter's detached state)
                callback?.onStateChanged(AppLifecycleState.detached)
            }
        }
    }
}
