import Foundation
import UIKit // Required for UIApplication, NotificationCenter

// Define a simple callback protocol to notify about lifecycle changes.
protocol ApzAppSwitchStateCallback: AnyObject { // Use AnyObject for weak reference
    func onStateChanged(state: AppLifecycleState)
}

// Enum representing the app lifecycle states, mirroring Flutter's AppLifecycleState.
// The rawValue strings are used to match the Dart enum names for EventChannel mapping.
enum AppLifecycleState: String {
    case resumed    
    case inactive   
    case paused     
    case detached  
}

/**
 * Manages the detection of iOS app lifecycle states and notifies a callback.
 *
 * This class observes `UIApplication` notifications via `NotificationCenter`
 * to track when the app becomes active, inactive, enters background, or terminates.
 */
class ApzAppSwitchStateDetector {
    weak var delegate: ApzAppSwitchStateCallback? // Use weak to avoid retain cycles

    /**
     * Initializes the detector and starts observing `UIApplication` notifications.
     * Call this once to set up the native listeners.
     *
     * @param delegate The delegate to receive lifecycle state changes.
     */
    init(delegate: ApzAppSwitchStateCallback) {
        self.delegate = delegate
        setupObservers()
    }

    /**
     * Sets up observers for relevant `UIApplication` notifications.
     */
    private func setupObservers() {
        // App became active (foreground and interactive)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        // App is about to become inactive (e.g., incoming phone call, system dialog)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )

        // App entered background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        // App is about to enter foreground (from background)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )

        // App is about to terminate
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
    }

    /**
     * Removes all registered observers.
     * Call this when the detector is no longer needed (e.g., when the Flutter engine is destroyed).
     */
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Notification Handlers

    @objc private func appDidBecomeActive() {
        delegate?.onStateChanged(state: .resumed)
    }

    @objc private func appWillResignActive() {
        delegate?.onStateChanged(state: .inactive)
    }

    @objc private func appDidEnterBackground() {
        delegate?.onStateChanged(state: .paused)
    }

    @objc private func appWillEnterForeground() {
    }

    @objc private func appWillTerminate() {
        delegate?.onStateChanged(state: .detached)
    }
}


