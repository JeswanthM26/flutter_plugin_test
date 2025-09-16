package com.iexceed.apz_network_state_perm

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiManager
import android.telephony.TelephonyManager
import android.telephony.SignalStrength
import android.telephony.PhoneStateListener
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.net.NetworkInterface
import java.net.Inet4Address

class ApzNetworkStatePerm : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  private var signalStrength: Int = -1
  private var telephonyManager: TelephonyManager? = null

  private var downSpeedMbps: Double = -1.0
  private var upSpeedMbps: Double = -1.0


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "network_info_plugin")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext

    // Initialize telephony manager and listener
    try {
      telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
      telephonyManager?.listen(object : PhoneStateListener() {
        override fun onSignalStrengthsChanged(signalStrengthObj: SignalStrength) {
          super.onSignalStrengthsChanged(signalStrengthObj)
          signalStrength = signalStrengthObj.level // 0 (worst) to 4 (best)
        }
      }, PhoneStateListener.LISTEN_SIGNAL_STRENGTHS)
    } catch (e: Exception) {
        // Do Nothing
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    if (call.method == "getNetworkDetails") {
        try {
            val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager

            val capabilities = connectivityManager.getNetworkCapabilities(connectivityManager.activeNetwork)
            val isVpn = capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true

            val isWifi = capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true
            val isMobile = capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) == true

          

           

            // Get IP address using improved method
            val ipAddress = getDeviceIpAddress()
            val data = mutableMapOf<String, Any?>(
                "isVpn" to isVpn,
                "ipAddress" to ipAddress
            )


            if (isWifi) {
                val wifiInfo = wifiManager.connectionInfo
                val wifiLinkSpeed = wifiInfo.linkSpeed // in Mbps
                val wifiSSID = wifiInfo.ssid?.replace("\"", "") ?: "Unknown" // Remove quotes from SSID
                data["connectionType"] = "WiFi"
                data["ssid"] = wifiSSID
                data["bandwidthMbps"] = wifiLinkSpeed
                data["signalStrengthLevel"] = signalStrength // Cellular signal strength (as requested)
            } else if (isMobile) {
                val operator = telephonyManager.networkOperator
                  val estimatedSpeed = getEstimatedMobileBandwidth()
                data["connectionType"] = "Mobile"
                data["carrierName"] = telephonyManager.networkOperatorName
               data["bandwidthMbps"] = downSpeedMbps
                // Fix MCC/MNC extraction
                if (operator.length >= 5) {
                    data["mcc"] = operator.substring(0, 3)
                    data["mnc"] = operator.substring(3)
                } else if (operator.length >= 3) {
                    data["mcc"] = operator.substring(0, 3)
                    data["mnc"] = if (operator.length > 3) operator.substring(3) else "Unknown"
                } else {
                    data["mcc"] = "Unknown"
                    data["mnc"] = "Unknown"
                }
                
                data["networkType"] = telephonyManager.networkType
                data["signalStrengthLevel"] = signalStrength // This is cellular signal strength
            } else {
                data["connectionType"] = "Unknown"
            }

            result.success(data)
        } catch (e: Exception) {
            result.error("NETWORK_ERROR", "Failed to get network details", e.message)
        }
    } else {
        result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    // Clean up telephony listener
    try {
      telephonyManager?.listen(null, PhoneStateListener.LISTEN_NONE)
    } catch (e: Exception) {
        // Do Nothing
    }
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    try {
      val telephonyManager = binding.activity.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

      telephonyManager.listen(object : PhoneStateListener() {
          override fun onSignalStrengthsChanged(signalStrengthObj: SignalStrength) {
              signalStrength = signalStrengthObj.level
          }
      }, PhoneStateListener.LISTEN_SIGNAL_STRENGTHS)
    } catch (e: Exception) {
        // Do Nothing
    }
  }

  override fun onDetachedFromActivity() {
    // Do Nothing
  }
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    // Do Nothing
  }
  override fun onDetachedFromActivityForConfigChanges() {
    // Do Nothing
  }

  private fun getDeviceIpAddress(): String {
      try {
          val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
          val network = connectivityManager.activeNetwork ?: return "Unknown"
          val caps = connectivityManager.getNetworkCapabilities(network)
          if (caps != null) {
            var downSpeed = caps.getLinkDownstreamBandwidthKbps();
            var upSpeed = caps.getLinkUpstreamBandwidthKbps(); 
             downSpeedMbps = downSpeed / 1000.0
             upSpeedMbps = upSpeed / 1000.0

              return when {
                  caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> {
                      // Use the original working WiFi method
                      getWifiIpAddressOriginal()
                  }
                  caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> {
                      // For mobile, use interface method
                      getIpFromInterfaces()
                  }
                  else -> getIpFromInterfaces()
              }
          } else {
              return "Unknown"
          }
      } catch (e: Exception) {
          return "Unknown"
      }
  }

  private fun getWifiIpAddressOriginal(): String {
      try {
          // Use context.getSystemService as in your original working code
          val wifiManager = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
          val ip = wifiManager.connectionInfo.ipAddress
          
          if (ip != 0) {
              val ipAddress = String.format(
                  "%d.%d.%d.%d",
                  (ip and 0xff),
                  (ip shr 8 and 0xff),
                  (ip shr 16 and 0xff),
                  (ip shr 24 and 0xff)
              )
              return ipAddress
          }
      } catch (e: Exception) {
        // Do Nothing
      }
      return "Unknown"
  }

  private fun getIpFromInterfaces(): String {
      try {
          val interfaces = NetworkInterface.getNetworkInterfaces()
          
          for (networkInterface in interfaces) {
              
              // Skip loopback and inactive interfaces
              if (networkInterface.isLoopback || !networkInterface.isUp) {
                  continue
              }
              
              val addresses = networkInterface.inetAddresses
              for (address in addresses) {
                  
                  // Only get IPv4 addresses that are not loopback
                  if (!address.isLoopbackAddress && address is Inet4Address) {
                      val hostAddress = address.hostAddress
                      
                      if (hostAddress != null && hostAddress.isNotEmpty() && hostAddress != "0.0.0.0") {
                          return hostAddress
                      }
                  }
              }
          }
      } catch (e: Exception) {
        // Do Nothing
      }
      
      return "Unknown"
  }

private fun getEstimatedMobileBandwidth(): String {
    return try {
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val networkType = telephonyManager.networkType  // No READ_PHONE_STATE required

        when (networkType) {
            TelephonyManager.NETWORK_TYPE_LTE -> "Approx 10–100 Mbps (4G)"
            TelephonyManager.NETWORK_TYPE_NR -> "Approx 100 Mbps–1 Gbps (5G)"
            TelephonyManager.NETWORK_TYPE_HSPA -> "Approx 700 kbps–2 Mbps (3G)"
            TelephonyManager.NETWORK_TYPE_EDGE -> "Approx 100–400 kbps (2G)"
            TelephonyManager.NETWORK_TYPE_GPRS -> "Approx 100 kbps (2G)"
            TelephonyManager.NETWORK_TYPE_UNKNOWN -> "Unknown"
            else -> "Unknown"
        }
    } catch (e: Exception) {
        "Unknown"
    }
}



}