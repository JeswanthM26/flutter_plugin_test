import Flutter
import UIKit
import CoreTelephony
import Network

public class ApzDeviceFingerprint: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.iexceed/apz_device_fingerprint", binaryMessenger: registrar.messenger())
    let instance = ApzDeviceFingerprint()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getDeviceFingerprint":
      self.getData { data in
        result(data)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getData(completion: @escaping ([String: String]) -> Void) {
        
        self.getNetworkConnectionType { connectionType in
            let nullString = "null"
            var data: [String: String] = [:]

            data["source"] = "iOS"
            data["secureId"] = ""
            data["deviceManufacturer"] = "Apple"
            
            let deviceModel = self.getDeviceModel()
            if (!deviceModel.isEmpty) {
                data["deviceModel"] = deviceModel
            } else {
                data["deviceModel"] = nullString
            }
            
            let screenResolution = self.getScreenResolution()
            data["screenResolution"] = "\(screenResolution.0) x \(screenResolution.1) pixels"
            
            let deviceType = self.getDeviceType()
            data["deviceType"] = deviceType
            
            let totalDiskSpace = self.getTotalDiskSpace()
            if (!totalDiskSpace.isEmpty) {
                data["totalDiskSpace"] = totalDiskSpace
            } else {
                data["totalDiskSpace"] = nullString
            }
            
            let totalRAM = self.getTotalRAM()
            data["totalRAM"] = totalRAM
            
            let cpuCount = self.getCPUCount()
            data["cpuCount"] = "\(cpuCount)"
            
            let cpuArchitecture = self.getCPUArchitecture()
            if (!cpuArchitecture.isEmpty) {
                data["cpuArchitecture"] = cpuArchitecture
            } else {
                data["cpuArchitecture"] = nullString
            }
            
            let cpuEndianness = self.getCPUEndianness()
            data["cpuEndianness"] = cpuEndianness
            
            let deviceName = self.getDeviceName()
            data["deviceName"] = deviceName
            
            data["glesVersion"] = "N/A"
            
            let osVersion = self.getOSVersion()
            data["osVersion"] = osVersion
            
            let osBuildNumber = self.getOSBuildNumber()
            if (osBuildNumber != nil && !osBuildNumber!.isEmpty) {
                data["osBuildNumber"] = osBuildNumber
            } else {
                data["osBuildNumber"] = nullString
            }
            
            let kernelVersion = self.getKernelVersion()
            if (kernelVersion != nil && !kernelVersion!.isEmpty) {
                data["kernelVersion"] = kernelVersion!
            } else {
                data["kernelVersion"] = nullString
            }
            
            let enabledKeyboardLanguages = self.getEnabledKeyboardLanguages()
            if (!enabledKeyboardLanguages.isEmpty) {
                data["enabledKeyboardLanguages"] = enabledKeyboardLanguages.joined(separator: ",")
            } else {
                data["enabledKeyboardLanguages"] = nullString
            }
            
            let identifierForVendor = self.getIdentifierForVendor()
            if (identifierForVendor != nil && !identifierForVendor!.isEmpty) {
                data["installId"] = identifierForVendor
            } else {
                data["installId"] = nullString
            }

            let timeZone = self.getTimeZone()
             data["timeZone"] = timeZone
            
            data["connectionType"] = connectionType
            
            let freeDiskSpace = self.getFreeDiskSpace()
            if (!freeDiskSpace.isEmpty) {
                data["freeDiskSpace"] = freeDiskSpace
            } else {
                data["freeDiskSpace"] = nullString
            }
            
            completion(data)
        }
    }
    
    // This will not change
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        if ["i386", "x86_64", "arm64"].contains(identifier) {
            let device = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "Simulator"
            return "Simulator (\(device))"
        }
        
        return identifier
    }
    
    // This will not change
    private func getScreenResolution() -> (CGFloat, CGFloat) {
        let nativeResolution = UIScreen.main.nativeBounds.size
        let screenWidthInPixels = nativeResolution.width
        let screenHeightInPixels = nativeResolution.height
        
        return (screenWidthInPixels, screenHeightInPixels)
    }
    
    // This will not change
    private func getDeviceType() -> String {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "iPhone"
        case .pad:
            return "iPad"
        case .tv:
            return "Apple TV"
        case .mac:
            return "Mac"
        case .vision:
            return "Apple Vision Pro"
        case .carPlay:
            return "CarPlay"
        case .unspecified:
            return "Unknown"
        @unknown default:
            return "Unknown"
        }
    }
    
    /*
     This will not change
     
     Privacy Manifest: As of iOS 17, accessing disk space information requires a declaration in your app's PrivacyInfo.xcprivacy file.
     You must provide a reason for using this API.
     
     Example--->
     API Used: URL.resourceValues(forKeys:)
     Reason Code: For example, use 85F4.1 if you need to check for sufficient disk space before downloading files.
     */
    private func getTotalDiskSpace() -> String {
        do {
            let homeDirectory = URL(fileURLWithPath: NSHomeDirectory())
            let resourceValues = try homeDirectory.resourceValues(forKeys: [.volumeTotalCapacityKey])
            if let totalCapacity = resourceValues.volumeTotalCapacity {
                let formattedCapacity = ByteCountFormatter.string(fromByteCount: Int64(totalCapacity), countStyle: .file)
                return formattedCapacity
            }
        } catch {
            print("Error retrieving total disk space: \(error.localizedDescription)")
        }
        
        return ""
    }
    
    /*
     This will not change
     
     Accessing the device's RAM is considered a "Required Reason API" by Apple, as it can be used for device fingerprinting. You must declare your reason for using this API in your app's PrivacyInfo.xcprivacy file.
     
     API Category: NSPrivacyAccessedAPICategoryMemoryFootprint
     
     Reason Code(s): You must provide a reason from Apple's list. For example, C5B7.1 allows you to "Access the device’s memory footprint to determine if the app is a candidate for memory-intensive features."
     */
    private func getTotalRAM() -> String {
        let totalRAM = ProcessInfo.processInfo.physicalMemory
        let formattedRAM = ByteCountFormatter.string(fromByteCount: Int64(totalRAM), countStyle: .memory)
        
        return formattedRAM
    }
    
    // This will not change
    private func getCPUCount() -> Int {
        let totalCoreCount = ProcessInfo.processInfo.processorCount
        return totalCoreCount
    }
    
    // This will not change
    private func getCPUArchitecture() -> String {
        var size = MemoryLayout<cpu_type_t>.size
        var cpuType: cpu_type_t = 0
        
        let result = sysctlbyname("hw.cputype", &cpuType, &size, nil, 0)
        
        guard result == 0 else {
            return "unknown"
        }
        
        switch cpuType {
        case CPU_TYPE_ARM64:
            return "arm64"
        case CPU_TYPE_X86_64:
            return "x86_64"
        case CPU_TYPE_X86:
            return "x86"
        case CPU_TYPE_ARM:
            return "arm"
        case CPU_TYPE_POWERPC:
            return "powerpc"
        case CPU_TYPE_POWERPC64:
            return "powerpc64"
        case CPU_TYPE_I386:
            return "i386"
        case CPU_TYPE_SPARC:
            return "sparc"
        case CPU_TYPE_MC680x0:
            return "m68k"
        case CPU_TYPE_HPPA:
            return "hppa"
        case CPU_TYPE_MC88000:
            return "m88k"
        case CPU_TYPE_VAX:
            return "vax"
        default:
            return "unknown(\(cpuType))"
        }
    }
    
    /*
     This will not change
     
     Endianness refers to how a processor stores multi-byte numbers in memory. While all modern Apple devices (iPhone, iPad, Mac with Apple silicon) are little-endian, you can still verify this programmatically.
     
     Little-Endian: The least significant byte is stored at the smallest memory address. (e.g., 0x12345678 is stored as 78 56 34 12).
     
     Big-Endian: The most significant byte is stored at the smallest memory address. (e.g., 0x12345678 is stored as 12 34 56 78).
     
     
     */
    private func getCPUEndianness() -> String {
        let number: UInt32 = 0x12345678
        let isLittleEndian = (number == number.littleEndian)
        
        if isLittleEndian {
            return "Little-Endian"
        } else {
            return "Big-Endian"
        }
    }
    
    /*
     This will not change frequently
     
     User-Defined: This name can be changed by the user at any time and can be any string they choose, including an empty one. Do not rely on it for a unique or permanent identifier.
     
     Privacy in iOS 16+: For privacy reasons, starting with iOS 16, directly accessing UIDevice.current.name will return a generic name (e.g., "iPhone" or "iPad") unless your app has a specific entitlement.
     
     Special Entitlement: To get the actual user-assigned name on iOS 16 and later, you must request the com.apple.developer.device-information.user-assigned-device-name entitlement from Apple. This is typically granted only to apps that need the name for multi-device functionality that is visible to the user (like device syncing).
     */
    private func getDeviceName() -> String {
        let deviceName = ProcessInfo.processInfo.hostName
        
        return deviceName
    }
    
    // OS version will change on OS update
    private func getOSVersion() -> String {
        let osVersionString = UIDevice.current.systemVersion
        return osVersionString
    }
    
    // OS Build number will change on OS update
    private func getOSBuildNumber() -> String? {
        var mib = [CTL_KERN, KERN_OSVERSION]
        var size: size_t = 0
        
        // First, call sysctl to determine the size of the buffer needed.
        if sysctl(&mib, u_int(mib.count), nil, &size, nil, 0) != 0 {
            perror("sysctl") // An error occurred
            return nil
        }
        
        // Create a buffer of the correct size to hold the C-style string.
        var buffer = [CChar](repeating: 0, count: size)
        
        // Now, call sysctl again to retrieve the actual data.
        if sysctl(&mib, u_int(mib.count), &buffer, &size, nil, 0) != 0 {
            perror("sysctl") // An error occurred
            return nil
        }
        
        // Convert the C-style string from the buffer into a Swift String.
        return String(cString: buffer)
    }
    
    // Kernel Version will change on OS update
    private func getKernelVersion() -> String? {
        var mib = [CTL_KERN, KERN_VERSION]
        var size: size_t = 0
        
        // Call sysctl to determine the size of the buffer needed
        if sysctl(&mib, u_int(mib.count), nil, &size, nil, 0) != 0 {
            perror("sysctl")
            return nil
        }
        
        // Create a buffer of the correct size
        var buffer = [CChar](repeating: 0, count: size)
        
        // Call sysctl again to retrieve the actual kernel version string
        if sysctl(&mib, u_int(mib.count), &buffer, &size, nil, 0) != 0 {
            perror("sysctl")
            return nil
        }
        
        // Convert the C-style string from the buffer into a Swift String
        return String(cString: buffer)
    }
    
    // This will change rarely
    private func getEnabledKeyboardLanguages() -> [String] {
        var languageIdentifiers: [String] = []
        
        // UITextInputMode.activeInputModes returns an array of currently active input modes.
        // This includes languages enabled by the user in Settings -> General -> Keyboard -> Keyboards.
        for inputMode in UITextInputMode.activeInputModes {
            if let primaryLanguage = inputMode.primaryLanguage {
                // primaryLanguage typically gives the BCP-47 language tag (e.g., "en-US", "es-ES", "hi-IN").
                languageIdentifiers.append(primaryLanguage)
            }
        }
        
        // You might want to get unique values and sort them
        return Array(Set(languageIdentifiers)).sorted()
    }

    private func getTimeZone() -> String {
        let timeZone = TimeZone.current
        let timeZoneIdentifier = timeZone.identifier
        let timeZoneAbbreviation = timeZone.abbreviation() ?? "Unknown"
        return timeZoneIdentifier
    }
    
    // This will change frequently
    private func getNetworkConnectionType(completion: @escaping (String) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkCheckQueue", qos: .background)
        
        monitor.pathUpdateHandler = { path in
            var connectionType = "NONE"
            if path.status == .satisfied {
                if path.usesInterfaceType(.wifi) {
                    connectionType = "WIFI"
                } else if path.usesInterfaceType(.cellular) {
                    connectionType = "CELLULAR"
                } else if path.usesInterfaceType(.wiredEthernet) {
                    connectionType = "ETHERNET"
                } else {
                    connectionType = "UNKNOWN"
                }
            } else {
                connectionType = "NONE"
            }
            monitor.cancel()
            DispatchQueue.main.async {
                completion(connectionType)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    /*
     This will change frequently
     
     Accessing disk space information requires you to declare a reason in your app's PrivacyInfo.xcprivacy file. Apple mandates this because this API can be used for device fingerprinting.
     
     API Category: NSPrivacyAccessedAPICategoryDiskSpace
     
     Reason Code(s): You must provide a reason. A common one is E174.1, which is used to "check for sufficient disk space before writing files or to manage disk space by deleting files from your app’s container, app group container, or CloudKit container."
     */
    private func getFreeDiskSpace() -> String {
        do {
            let homeDirectory = URL(fileURLWithPath: NSHomeDirectory())
            let resourceValues = try homeDirectory.resourceValues(forKeys: [.volumeAvailableCapacityKey])
            
            if let availableCapacity = resourceValues.volumeAvailableCapacity {
                let formattedCapacity = ByteCountFormatter.string(fromByteCount: Int64(availableCapacity), countStyle: .file)
                return formattedCapacity
            }
        } catch {
            print("Error retrieving free disk space: \(error.localizedDescription)")
        }
        
        return ""
    }
    
    /*
     This will change on every install
     
     The IDFV is a unique identifier shared by all apps from the same developer on a single device.
     It remains consistent as long as at least one of the vendor's apps is installed.
     */
    private func getIdentifierForVendor() -> String? {
        if let idfv = UIDevice.current.identifierForVendor {
            return idfv.uuidString
        }
        return nil
    }
}