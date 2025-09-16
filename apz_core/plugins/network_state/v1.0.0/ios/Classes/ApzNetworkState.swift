import CoreTelephony
import Flutter
import Network
import SystemConfiguration.CaptiveNetwork
import UIKit

public class ApzNetworkState: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "network_info_plugin", binaryMessenger: registrar.messenger())
    let instance = ApzNetworkState()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getNetworkDetails" {
      self.getNetworkDetails { data in
        var resultData = data
        let args = call.arguments as? [String: String]
        guard let urlString = args?["url"] else {
          resultData["latency"] = 0.0
          result(resultData)
          return
        }

        self.measureLatency(to: urlString) { timeInterval in
          if timeInterval != nil {
            resultData["latency"] = timeInterval
          } else {
            resultData["latency"] = 0.0
          }
          
          result(resultData)
        }
      }
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func getNetworkDetails(callback: @escaping ([String: Any]) -> Void) {
    var data = [String: Any]()

    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "NetworkMonitor")

    monitor.pathUpdateHandler = { path in
      monitor.cancel()

      data["isVpn"] = VPNDetector().isVPNConnected()
      data["ipAddress"] = self.getWiFiAddress() ?? "Unknown"

      if path.usesInterfaceType(.wifi) {
        data["connectionType"] = "WiFi"
        data["ssid"] = self.getWiFiSSID() ?? "Unknown"
        data["bandwidthMbps"] = -1  // iOS does not provide WiFi bandwidth directly
        data["signalStrengthLevel"] = -1  // Not accessible in iOS

      } else if path.usesInterfaceType(.cellular) {
        data["connectionType"] = "Mobile"
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.serviceSubscriberCellularProviders?.first?.value
        let radioAccess = networkInfo.serviceCurrentRadioAccessTechnology?.first?.value ?? "Unknown"
        switch radioAccess {
        case CTRadioAccessTechnologyLTE:
          data["networkType"] = "4G"
        case CTRadioAccessTechnologyNR, CTRadioAccessTechnologyNRNSA:
          data["networkType"] = "5G"
        case CTRadioAccessTechnologyWCDMA,
          CTRadioAccessTechnologyHSDPA,
          CTRadioAccessTechnologyHSUPA,
          CTRadioAccessTechnologyCDMAEVDORev0,
          CTRadioAccessTechnologyCDMAEVDORevA,
          CTRadioAccessTechnologyCDMAEVDORevB,
          CTRadioAccessTechnologyeHRPD:
          data["networkType"] = "3G"
        case CTRadioAccessTechnologyGPRS,
          CTRadioAccessTechnologyEdge:
          data["networkType"] = "2G"
        default:
          data["networkType"] = radioAccess
        }
        data["mcc"] = carrier?.mobileCountryCode ?? "Unknown"
        data["mnc"] = carrier?.mobileNetworkCode ?? "Unknown"
        data["bandwidthMbps"] = -1  // Not available
        data["signalStrengthLevel"] = -1  // Not accessible via public APIs

      } else {
        data["connectionType"] = "Unknown"
      }

      callback(data)
    }

    monitor.start(queue: queue)
  }

  private func getWiFiSSID() -> String? {
    if let interfaces = CNCopySupportedInterfaces() as NSArray? {
      for interface in interfaces {
        if let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interface as! CFString)
          as NSDictionary?
        {
          return unsafeInterfaceData["SSID"] as? String
        }
      }
    }
    return nil
  }

  private func getWiFiAddress() -> String? {
    var address: String?

    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    if getifaddrs(&ifaddr) == 0 {
      var ptr = ifaddr
      while ptr != nil {
        defer { ptr = ptr!.pointee.ifa_next }

        let interface = ptr!.pointee
        let addrFamily = interface.ifa_addr.pointee.sa_family

        if addrFamily == UInt8(AF_INET) {
          if let name = String(validatingUTF8: interface.ifa_name), name == "en0" {
            var addr = interface.ifa_addr.pointee
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            getnameinfo(
              &addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname,
              socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
            address = String(cString: hostname)
            break
          }
        }
      }
      freeifaddrs(ifaddr)
    }
    return address
  }

  func measureLatency(to urlString: String, completion: @escaping (TimeInterval?) -> Void) {
    let startTime = CFAbsoluteTimeGetCurrent()

    guard let url = URL(string: urlString) else {
      completion(nil)
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "HEAD"
    request.timeoutInterval = 5.0

    URLSession.shared.dataTask(with: request) { _, response, error in
      guard error == nil, response != nil else {
        completion(nil)
        return
      }

      let latency = CFAbsoluteTimeGetCurrent() - startTime
      completion(latency)
    }.resume()
  }
}
