import UIKit

struct DeviceModel {
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelIdentifier = withUnsafePointer(to: &systemInfo.machine) { ptr in
            ptr.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? "Unknown"
            }
        }
        return mapToDeviceName(identifier: modelIdentifier)
    }()
    
    private static func mapToDeviceName(identifier: String) -> String {
        let deviceMap: [String: String] = [
            "iPhone10,1": "iPhone 8",
            "iPhone10,4": "iPhone 8",
            "iPhone10,2": "iPhone 8 Plus",
            "iPhone10,5": "iPhone 8 Plus",
            "iPhone10,3": "iPhone X",
            "iPhone10,6": "iPhone X",
            "iPhone11,2": "iPhone XS",
            "iPhone11,4": "iPhone XS Max",
            "iPhone11,6": "iPhone XS Max",
            "iPhone11,8": "iPhone XR",
            "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",
            "iPhone13,1": "iPhone 12 Mini",
            "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone14,2": "iPhone 13",
            "iPhone14,3": "iPhone 13 Mini",
            "iPhone14,4": "iPhone 13 Pro",
            "iPhone14,5": "iPhone 13 Pro Max",
            "iPhone14,6": "iPhone SE (3rd generation)",
            "iPhone15,4": "iPhone 14",
            "iPhone15,5": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone16,1": "iPhone 15",
            "iPhone16,2": "iPhone 15 Plus",
            "iPhone16,3": "iPhone 15 Pro",
            "iPhone16,4": "iPhone 15 Pro Max",
            
        ]
        return deviceMap[identifier] ?? identifier
    }
}
