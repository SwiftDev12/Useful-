import Network
import SystemConfiguration.CaptiveNetwork
import CoreTelephony
import CoreLocation

class NetworkInfo: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = NetworkInfo()
    
    @Published var ssid: String = "Unknown"
    @Published var bssid: String = "Unknown"
    @Published var ipAddress: String = "Unknown"
    @Published var carrierName: String = "Unknown"
    
    private var timer: Timer?
    private var locationManager: CLLocationManager?
    
    private override init() {
        super.init()
        startMonitoring()
    }
    
    func startMonitoring() {
        setupLocationManager()
        updateNetworkInfo()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.updateNetworkInfo()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            updateNetworkInfo()
        }
    }
    
    private func updateNetworkInfo() {
        getWiFiInfo()
        getIPAddress()
        getCarrierInfo()
    }
    
    private func getWiFiInfo() {
        guard let interfaces = CNCopySupportedInterfaces() as? [String], !interfaces.isEmpty else {
            print("No Wi-Fi interfaces found")
            return
        }
        
        for interface in interfaces {
            if let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: AnyObject] {
                ssid = unsafeInterfaceData[kCNNetworkInfoKeySSID as String] as? String ?? "Unknown"
                bssid = unsafeInterfaceData[kCNNetworkInfoKeyBSSID as String] as? String ?? "Unknown"
                print("SSID: \(ssid), BSSID: \(bssid)")
                return
            }
        }
        print("Could not retrieve Wi-Fi info")
    }
    
    private func getIPAddress() {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return }
        guard let firstAddr = ifaddr else { return }
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                if let name = String(validatingUTF8: interface.ifa_name), name == "en0" {
                    var addr = interface.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        ipAddress = address ?? "Unknown"
    }
    
    private func getCarrierInfo() {
        let networkInfo = CTTelephonyNetworkInfo()
        if let carrier = networkInfo.subscriberCellularProvider {
            carrierName = carrier.carrierName ?? "Unknown"
        } else {
            carrierName = "No SIM"
        }
    }
}
