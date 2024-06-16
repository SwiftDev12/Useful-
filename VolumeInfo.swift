import Foundation
import AVFoundation
import MediaPlayer

class VolumeInfo: NSObject, ObservableObject {
    static let shared = VolumeInfo()
    
    @Published var volume: Float = AVAudioSession.sharedInstance().outputVolume
    private var volumeView: MPVolumeView!
    
    override init() {
        super.init()
        setupVolumeView()
        observeVolumeChanges()
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func startMonitoring() {
        
    }
    
    private func setupVolumeView() {
        volumeView = MPVolumeView(frame: .zero)
        volumeView.isHidden = true
        if let window = UIApplication.shared.windows.first {
            window.addSubview(volumeView)
        }
    }
    
    private func observeVolumeChanges() {
        NotificationCenter.default.addObserver(self, selector: #selector(volumeDidChange), name: NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
    }
    
    @objc private func volumeDidChange(notification: NSNotification) {
        if let volume = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
            DispatchQueue.main.async {
                self.volume = volume
            }
        }
    }
}
