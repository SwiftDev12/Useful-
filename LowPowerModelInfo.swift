import Foundation
import UIKit

class LowPowerModeInfo: ObservableObject {
    static let shared = LowPowerModeInfo()
    
    @Published var isLowPowerModeEnabled: Bool = ProcessInfo.processInfo.isLowPowerModeEnabled
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(lowPowerModeStatusChanged), name: .NSProcessInfoPowerStateDidChange, object: nil)
    }
    
    @objc private func lowPowerModeStatusChanged(notification: Notification) {
        self.isLowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
    }
}
