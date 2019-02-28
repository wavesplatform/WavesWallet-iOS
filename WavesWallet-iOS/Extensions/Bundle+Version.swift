//
//  Bundle+Version.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 11/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import CoreTelephony

private struct DeviceIdStorage: TSUD {
    
    private static let key: String = "com.waves.device.id"
    
    static var defaultValue: String? {
        return nil
    }
    
    static var stringKey: String {
        return DeviceIdStorage.key
    }
}

extension UIDevice {

    var osVersion: String {
        get {
            return UIDevice.current.systemVersion
        }
    }

    var appVersion: String {
        get {
            return Bundle.main.version
        }
    }

    var deviceModel: String {
        get {
            return UIDevice.current.modelName
        }
    }

    var language: String {
        get {
            return NSLocale.preferredLanguages.first ?? ""
        }
    }

    var carrierName: String {
        get {
            let info = CTTelephonyNetworkInfo()
            guard let carrier = info.subscriberCellularProvider else { return "" }
            return carrier.carrierName ?? ""
        }
    }
    
    static var uuid: String {
        
        if let id = DeviceIdStorage.value {
            return id
        } else {
            let id = UUID().uuidString
            DeviceIdStorage.value = id
            return id
        }
    }

    func deviceDescription() -> String {
        return "\n\n\n\n---Device Info---" +
            "\nOS Version: \(osVersion)" +
            "\nApp Version: \(appVersion)" +
            "\nDevice Model: \(deviceModel)" +
            "\nLanguage: \(language)" +
            "\nCarrier: \(carrierName)" +
            "\nDeviceUUID: \(UIDevice.uuid)"
    }
}

extension Bundle {

    var version: String {

        let dictionary = Bundle.main.infoDictionary!
        let version = (dictionary["CFBundleShortVersionString"] as? String) ?? ""
        let build = (dictionary["CFBundleVersion"] as? String) ?? ""

        return "\(version) (\(build))"
    }
}

fileprivate extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
