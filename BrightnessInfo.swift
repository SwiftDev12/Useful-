import Foundation
import UIKit

class BrightnessInfo: ObservableObject {
    static let shared = BrightnessInfo()
    
    @Published var brightness: Float = Float(UIScreen.main.brightness)
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(brightnessDidChange), name: UIScreen.brightnessDidChangeNotification, object: nil)
    }
    
    @objc private func brightnessDidChange(_ notification: Notification) {
        self.brightness = Float(UIScreen.main.brightness)
    }
}
