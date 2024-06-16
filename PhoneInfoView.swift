import SwiftUI

struct PhoneInfoView: View {
    @StateObject private var batteryInfo = BatteryInfo.shared
    @StateObject private var brightnessInfo = BrightnessInfo.shared
    @StateObject private var volumeInfo = VolumeInfo.shared
    @StateObject private var lowPowerModeInfo = LowPowerModeInfo.shared
    @StateObject private var networkInfo = NetworkInfo.shared
    @StateObject private var deviceInfo = DeviceInfo.shared

    var body: some View {
        List {
            GeneralInformationSection(deviceInfo: deviceInfo)
            HardwareInformationSection(deviceInfo: deviceInfo)
            SystemInformationSection(deviceInfo: deviceInfo)
            AppInformationSection(deviceInfo: deviceInfo)
            NetworkInformationSection(networkInfo: networkInfo)
            BatteryInformationSection(batteryInfo: batteryInfo)
            TorchControlSection(deviceInfo: deviceInfo)
            CurrentAppStatusSection(deviceInfo: deviceInfo, brightnessInfo: brightnessInfo, volumeInfo: volumeInfo)
        }
        .navigationTitle("Phone Info")
        .listStyle(GroupedListStyle())
        .onAppear {
            startMonitoring()
        }
        .onDisappear {
            stopMonitoring()
        }
    }

    private func startMonitoring() {
        batteryInfo.startMonitoring()
        volumeInfo.startMonitoring()
        networkInfo.startMonitoring()
        deviceInfo.startMonitoring()
    }

    private func stopMonitoring() {
        batteryInfo.stopMonitoring()
        networkInfo.stopMonitoring()
        deviceInfo.stopMonitoring()
    }
}

struct GeneralInformationSection: View {
    @ObservedObject var deviceInfo: DeviceInfo

    var body: some View {
        Section(header: Text("General Information").font(.headline).padding(.top)) {
            InfoRow(label: "Model Name", value: deviceInfo.modelName)
            InfoRow(label: "System Name", value: UIDevice.current.systemName)
            InfoRow(label: "System Version", value: UIDevice.current.systemVersion)
            InfoRow(label: "Model", value: deviceInfo.modelIdentifier)
            InfoRow(label: "Localized Model", value: UIDevice.current.localizedModel)
            InfoRow(label: "Device Orientation", value: deviceInfo.deviceOrientation)
        }
    }
}

struct HardwareInformationSection: View {
    @ObservedObject var deviceInfo: DeviceInfo

    var body: some View {
        Section(header: Text("Hardware Information").font(.headline)) {
            InfoRow(label: "CPU Architecture", value: deviceInfo.cpuArchitecture)
            InfoRow(label: "CPU Cores", value: deviceInfo.cpuCores)
            InfoRow(label: "Total Disk Space", value: deviceInfo.totalDiskSpace)
            InfoRow(label: "Free Disk Space", value: deviceInfo.freeDiskSpace)
            InfoRow(label: "Screen Resolution", value: deviceInfo.screenResolution)
        }
    }
}

struct SystemInformationSection: View {
    @ObservedObject var deviceInfo: DeviceInfo

    var body: some View {
        Section(header: Text("System Information").font(.headline)) {
            InfoRow(label: "Available Memory", value: deviceInfo.availableMemory)
            InfoRow(label: "Used Memory", value: deviceInfo.usedMemory)
            InfoRow(label: "Total Memory", value: deviceInfo.totalMemory)
            InfoRow(label: "Device Language", value: deviceInfo.deviceLanguage)
            InfoRow(label: "Device Timezone", value: deviceInfo.deviceTimezone)
            InfoRow(label: "System Uptime", value: deviceInfo.systemUptime)
        }
    }
}

struct AppInformationSection: View {
    @ObservedObject var deviceInfo: DeviceInfo

    var body: some View {
        Section(header: Text("App Information").font(.headline)) {
            InfoRow(label: "App Version", value: deviceInfo.appVersion)
            InfoRow(label: "App Build Number", value: deviceInfo.appBuildNumber)
        }
    }
}

struct NetworkInformationSection: View {
    @ObservedObject var networkInfo: NetworkInfo

    var body: some View {
        Section(header: Text("Network Information").font(.headline)) {
            DisclosureGroup("Sensitive Information") {
                InfoRow(label: "Wi-Fi SSID", value: networkInfo.ssid)
                InfoRow(label: "Wi-Fi BSSID", value: networkInfo.bssid)
                InfoRow(label: "IP Address", value: networkInfo.ipAddress)
            }
            InfoRow(label: "Cellular Carrier", value: networkInfo.carrierName)
        }
    }
}

struct BatteryInformationSection: View {
    @ObservedObject var batteryInfo: BatteryInfo

    var body: some View {
        Section(header: Text("Battery Information").font(.headline)) {
            InfoRow(label: "Battery Health", value: batteryInfo.batteryHealth)
            InfoRow(label: "Battery State", value: batteryInfo.state.description)
            InfoRow(label: "Low Power Mode", value: batteryInfo.isLowPowerModeEnabled ? "Enabled" : "Disabled")
        }
    }
}

struct TorchControlSection: View {
    @ObservedObject var deviceInfo: DeviceInfo

    var body: some View {
        Section(header: Text("Torch Control").font(.headline)) {
            Button(action: deviceInfo.toggleTorch) {
                Text(deviceInfo.isTorchOn ? "Turn Torch Off" : "Turn Torch On")
            }
            Slider(value: $deviceInfo.torchBrightness, in: 0...1) {
                Text("Torch Brightness")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("1")
            }
            .disabled(!deviceInfo.isTorchOn)
            .onChange(of: deviceInfo.torchBrightness) { newValue in
                deviceInfo.setTorchLevel(level: newValue)
            }
        }
    }
}

struct CurrentAppStatusSection: View {
    @ObservedObject var deviceInfo: DeviceInfo
    @ObservedObject var brightnessInfo: BrightnessInfo
    @ObservedObject var volumeInfo: VolumeInfo

    var body: some View {
        Section(header: Text("Current App Status").font(.headline)) {
            InfoRow(label: "Sandbox Status", value: deviceInfo.isInSandbox ? "In Sandbox" : "Not in Sandbox")
            InfoRow(label: "App Size", value: deviceInfo.appSize)
            InfoRow(label: "Installed Browsers", value: deviceInfo.installedBrowsers.joined(separator: ", "))
            InfoRow(label: "Screen Brightness", value: "\(Int(brightnessInfo.brightness * 100))%")
            InfoRow(label: "Volume Level", value: "\(Int(volumeInfo.volume * 100))%")
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}
