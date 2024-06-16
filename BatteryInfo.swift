import Foundation
import UIKit

class BatteryInfo: ObservableObject {
    static let shared = BatteryInfo()
    
    @Published var level: Float = 0.0
    @Published var state: UIDevice.BatteryState = .unknown
    @Published var isLowPowerModeEnabled: Bool = ProcessInfo.processInfo.isLowPowerModeEnabled
    @Published var batteryHealth: String = "Unknown"
    
    private init() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        self.level = UIDevice.current.batteryLevel * 100
        self.state = UIDevice.current.batteryState
        self.isLowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
        
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(lowPowerModeStatusChanged), name: .NSProcessInfoPowerStateDidChange, object: nil)
    }
    
    func startMonitoring() {
        
    }
    
    func stopMonitoring() {
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryStateDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .NSProcessInfoPowerStateDidChange, object: nil)
    }
    
    @objc private func batteryLevelDidChange(_ notification: Notification) {
        self.level = UIDevice.current.batteryLevel * 100
    }
    
    @objc private func batteryStateDidChange(_ notification: Notification) {
        self.state = UIDevice.current.batteryState
    }
    
    @objc private func lowPowerModeStatusChanged(notification: Notification) {
        self.isLowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
    }
}

extension UIDevice.BatteryState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unplugged:
            return "Unplugged"
        case .charging:
            return "Charging"
        case .full:
            return "Full"
        case .unknown:
            fallthrough
        @unknown default:
            return "Unknown"
        }
    }
}
