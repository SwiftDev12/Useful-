import Foundation
import UIKit
import AVFoundation

class DeviceInfo: ObservableObject {
    static let shared = DeviceInfo()
    
    @Published var cpuArchitecture: String
    @Published var totalDiskSpace: String
    @Published var freeDiskSpace: String
    @Published var modelName: String
    @Published var screenResolution: String
    @Published var availableMemory: String
    @Published var usedMemory: String
    @Published var totalMemory: String
    @Published var deviceLanguage: String
    @Published var deviceTimezone: String
    @Published var systemUptime: String
    @Published var appVersion: String
    @Published var appBuildNumber: String
    @Published var cpuCores: String
    @Published var deviceOrientation: String
    @Published var screenBrightness: String
    @Published var availableStorageSpace: String
    @Published var batteryHealth: String
    @Published var isTorchOn: Bool = false
    @Published var torchBrightness: Float = 1.0
    @Published var isInSandbox: Bool
    @Published var appSize: String
    @Published var installedBrowsers: [String] = []
    @Published var modelIdentifier: String

    private var timer: Timer?
    
    private init() {
        self.cpuArchitecture = DeviceInfo.getCPUArchitecture()
        self.totalDiskSpace = DeviceInfo.getTotalDiskSpace()
        self.freeDiskSpace = DeviceInfo.getFreeDiskSpace()
        self.modelName = DeviceModel.modelName
        self.screenResolution = DeviceInfo.getScreenResolution()
        self.availableMemory = DeviceInfo.getAvailableMemory()
        self.usedMemory = DeviceInfo.getUsedMemory()
        self.totalMemory = DeviceInfo.getTotalMemory()
        self.deviceLanguage = Locale.current.languageCode ?? "Unknown"
        self.deviceTimezone = TimeZone.current.identifier
        self.systemUptime = DeviceInfo.getSystemUptime()
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        self.appBuildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        self.cpuCores = "\(ProcessInfo.processInfo.processorCount) Cores"
        self.deviceOrientation = DeviceInfo.getDeviceOrientation()
        self.screenBrightness = String(format: "%.0f%%", UIScreen.main.brightness * 100)
        self.availableStorageSpace = DeviceInfo.getAvailableStorageSpace()
        self.batteryHealth = BatteryInfo.shared.batteryHealth
        self.isInSandbox = DeviceInfo.checkSandboxStatus()
        self.appSize = DeviceInfo.getAppSize()
        self.installedBrowsers = DeviceInfo.getInstalledBrowsers()
        self.modelIdentifier = DeviceInfo.getModelIdentifier() // Initialize model identifier

        startMonitoring()
        startOrientationMonitoring()
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.updateDeviceInfo()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        stopOrientationMonitoring()
    }
    
    private func updateDeviceInfo() {
        self.cpuArchitecture = DeviceInfo.getCPUArchitecture()
        self.totalDiskSpace = DeviceInfo.getTotalDiskSpace()
        self.freeDiskSpace = DeviceInfo.getFreeDiskSpace()
        self.screenResolution = DeviceInfo.getScreenResolution()
        self.availableMemory = DeviceInfo.getAvailableMemory()
        self.usedMemory = DeviceInfo.getUsedMemory()
        self.totalMemory = DeviceInfo.getTotalMemory()
        self.deviceLanguage = Locale.current.languageCode ?? "Unknown"
        self.deviceTimezone = TimeZone.current.identifier
        self.systemUptime = DeviceInfo.getSystemUptime()
        self.cpuCores = "\(ProcessInfo.processInfo.processorCount) Cores"
        self.screenBrightness = String(format: "%.0f%%", UIScreen.main.brightness * 100)
        self.availableStorageSpace = DeviceInfo.getAvailableStorageSpace()
        self.batteryHealth = BatteryInfo.shared.batteryHealth
        self.isInSandbox = DeviceInfo.checkSandboxStatus()
        self.appSize = DeviceInfo.getAppSize()
        self.installedBrowsers = DeviceInfo.getInstalledBrowsers()
        self.modelIdentifier = DeviceInfo.getModelIdentifier() // Update model identifier
    }
    
    private static func getCPUArchitecture() -> String {
        var size: size_t = 0
        sysctlbyname("hw.cpusubtype", nil, &size, nil, 0)
        var cpusubtype = cpu_subtype_t(0)
        sysctlbyname("hw.cpusubtype", &cpusubtype, &size, nil, 0)
        
        switch cpusubtype {
        case CPU_SUBTYPE_ARM64E:
            return "ARM64e"
        default:
            return "ARM64"
        }
    }
    
    private static func getTotalDiskSpace() -> String {
        if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let space = systemAttributes[.systemSize] as? Int64 {
            return ByteCountFormatter.string(fromByteCount: space, countStyle: .file)
        } else {
            return "Unknown"
        }
    }
    
    private static func getFreeDiskSpace() -> String {
        if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let freeSpace = systemAttributes[.systemFreeSize] as? Int64 {
            return ByteCountFormatter.string(fromByteCount: freeSpace, countStyle: .file)
        } else {
            return "Unknown"
        }
    }
    
    private static func getScreenResolution() -> String {
        let screenSize = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        let resolution = CGSize(width: screenSize.width * scale, height: screenSize.height * scale)
        return "\(Int(resolution.width)) x \(Int(resolution.height))"
    }
    
    private static func getAvailableMemory() -> String {
        let memoryInfo = ProcessInfo.processInfo.physicalMemory
        return ByteCountFormatter.string(fromByteCount: Int64(memoryInfo), countStyle: .memory)
    }
    
    private static func getUsedMemory() -> String {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        if kerr == KERN_SUCCESS {
            return ByteCountFormatter.string(fromByteCount: Int64(taskInfo.resident_size), countStyle: .memory)
        } else {
            return "Unknown"
        }
    }
    
    private static func getTotalMemory() -> String {
        return ByteCountFormatter.string(fromByteCount: Int64(ProcessInfo.processInfo.physicalMemory), countStyle: .memory)
    }
    
    private static func getSystemUptime() -> String {
        let uptime = ProcessInfo.processInfo.systemUptime
        let days = Int(uptime / 86400)
        let hours = Int((uptime.truncatingRemainder(dividingBy: 86400)) / 3600)
        let minutes = Int((uptime.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(days) days, \(hours) hours, \(minutes) minutes"
    }
    
    private static func getDeviceOrientation() -> String {
        switch UIDevice.current.orientation {
        case .portrait:
            return "Portrait"
        case .portraitUpsideDown:
            return "Portrait Upside Down"
        case .landscapeLeft:
            return "Landscape Left"
        case .landscapeRight:
            return "Landscape Right"
        case .faceUp:
            return "Face Up"
        case .faceDown:
            return "Face Down"
        default:
            return "Unknown"
        }
    }
    
    private static func getAvailableStorageSpace() -> String {
        if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let freeSpace = systemAttributes[.systemFreeSize] as? Int64 {
            return ByteCountFormatter.string(fromByteCount: freeSpace, countStyle: .file)
        } else {
            return "Unknown"
        }
    }
    
    private static func checkSandboxStatus() -> Bool {
        return !Bundle.main.bundlePath.contains("/var/containers/Bundle/Application/")
    }
    
    private static func getAppSize() -> String {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: Bundle.main.bundlePath),
           let size = attributes[.size] as? Int64 {
            return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
        } else {
            return "Unknown"
        }
    }
    
    private static func getInstalledBrowsers() -> [String] {
        let browsers = [
            "Safari": "http://",
            "Chrome": "googlechrome://",
            "Firefox": "firefox://",
            "Edge": "microsoft-edge://",
            "Opera Touch": "touch-https://"
        ]
        
        var installedBrowsers: [String] = []
        
        for (name, scheme) in browsers {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                installedBrowsers.append(name)
            }
        }
        
        return installedBrowsers
    }
    
    private static func getModelIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return String(bytes: Data(bytes: &systemInfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) ?? "Unknown"
    }

    private func startOrientationMonitoring() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func stopOrientationMonitoring() {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc private func orientationDidChange() {
        self.deviceOrientation = DeviceInfo.getDeviceOrientation()
    }
    
    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            if isTorchOn {
                device.torchMode = .off
            } else {
                try device.setTorchModeOn(level: torchBrightness)
            }
            device.unlockForConfiguration()
            isTorchOn.toggle()
        } catch {
            print("Torch could not be used")
        }
    }
    
    func setTorchLevel(level: Float) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch, isTorchOn else { return }
        
        do {
            try device.lockForConfiguration()
            try device.setTorchModeOn(level: level)
            device.unlockForConfiguration()
        } catch {
            print("Torch brightness could not be adjusted")
        }
    }
}

