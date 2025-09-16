import Foundation
import Network

class VPNDetector {
    
    func isVPNConnected() -> Bool {
        return getVPNInterfaces().count > 0
    }
    
    private func getVPNInterfaces() -> [String] {
        var vpnInterfaces: [String] = []
        
        // Get list of all network interfaces
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return vpnInterfaces }
        guard let firstAddr = ifaddr else { return vpnInterfaces }
        
        var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            let interface = ptr?.pointee
            let addrFamily = interface?.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                let name = String(cString: interface!.ifa_name)
                
                // Check for VPN interface patterns
                if isVPNInterface(name) {
                    vpnInterfaces.append(name)
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return vpnInterfaces
    }
    
    private func isVPNInterface(_ name: String) -> Bool {
        // Common VPN interface prefixes
        let vpnPrefixes = [
            "tun",    // Tunnel interfaces
            "tap",    // TAP interfaces
            "ppp",    // Point-to-Point Protocol
            "ipsec",  // IPSec VPN
            "utun",   // User tunnel (iOS VPN)
            "tur"     // Some VPN implementations
        ]
        
        return vpnPrefixes.contains { name.hasPrefix($0) }
    }
}