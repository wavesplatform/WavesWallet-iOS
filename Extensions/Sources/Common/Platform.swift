import DeviceKit
import UIKit

public extension Platform {
    enum Inch: Double, Equatable {
        case inch3_5 = 3.5 // .iPhone4, iPhone4s
        case inch4 = 4 // .iPhone5, .iPhone5c, .iPhone5s, .iPhoneSE
        case inch4_7 = 4.7 // .iPhone6, .iPhone6s, .iPhone7, .iPhone8
        case inch5_5 = 5.5 // .iPhone6Plus, .iPhone6sPlus, .iPhone7Plus, .iPhone8Plus

        case inch5_8 = 5.8 // .iPhoneX, .iPhoneXS, .iPhone11Pro
        case inch6_1 = 6.1 // .iPhoneXR, .iPhone11

        case inch6_5 = 6.5 // .iPhoneXSMax, .iPhone11ProMax

        case inch7_9 = 7.9
        case inch9_7 = 9.7
        case inch10_5 = 10.5
        case inch12_9 = 12.9

        /// .iPhone4, iPhone4s, .iPhone5, .iPhone5c, .iPhone5s, .iPhoneSE
        public static var smallDevices: [Inch] { [.inch3_5, .inch4] }

        /// .iPhone6, .iPhone6s, .iPhone7, .iPhone8
        public static var mediumDevices: [Inch] { [.inch4_7] }
        
        /// .iPhone6Plus, .iPhone6sPlus, .iPhone7Plus, .iPhone8Plus, .iPhoneX, .iPhoneXS, .iPhone11Pro, .iPhoneXR, .iPhone11, .iPhoneXSMax, .iPhone11ProMax
        public static var largeDevices: [Inch] { [.inch5_5, .inch5_8, .inch6_1, .inch6_5] }
    }
}

public struct Platform {
    public static let ScreenWidth = UIScreen.main.bounds.width

    private static let device = Device.current

    public static var isSmallDevices: Bool {
        return Inch.smallDevices.contains(currentInch)
    }

    public static var isMediumDevices: Bool {
        return Inch.mediumDevices.contains(currentInch)
    }

    public static var isLargeDevices: Bool {
        return Inch.largeDevices.contains(currentInch)
    }

    public static var currentInch: Platform.Inch {
        return Platform.Inch(rawValue: device.diagonal) ?? Platform.Inch.inch4
    }

    @available(iOS, deprecated, message: "Use isSmallDevices")
    public static let isIphone5: Bool = {
        device.isOneOf([.iPhone5, .simulator(.iPhone5),
                        .iPhone5c, .simulator(.iPhone5c),
                        .iPhone5s, .simulator(.iPhone5s),
                        .iPhoneSE, .simulator(.iPhoneSE)])
    }()

    @available(iOS, deprecated, message: "Use isMediumDevices")
    public static let isIphone7: Bool = {
        device.isOneOf([.iPhone6, .simulator(.iPhone6),
                        .iPhone6s, .simulator(.iPhone6s),
                        .iPhone7, .simulator(.iPhone7),
                        .iPhone8, .simulator(.iPhone8)])
    }()

    public static let isIphoneXSeries: Bool = {
        device.isOneOf([.iPhoneX, .simulator(.iPhoneX),
                        .iPhoneXR, .simulator(.iPhoneXR),
                        .iPhoneXS, .simulator(.iPhoneXS),
                        .iPhoneXSMax, .simulator(.iPhoneXSMax),
                        .iPhone11, .simulator(.iPhone11),
                        .iPhone11Pro, .simulator(.iPhone11Pro),
                        .iPhone11ProMax, .simulator(.iPhone11ProMax)])
    }()

    @available(iOS, deprecated, message: "Use isLargeDevices")
    public static let isIphonePlus: Bool = {
        device.isOneOf([.iPhone6Plus, .simulator(.iPhone6Plus),
                        .iPhone6sPlus, .simulator(.iPhone6sPlus),
                        .iPhone7Plus, .simulator(.iPhone7Plus),
                        .iPhone8Plus, .simulator(.iPhone8Plus)])
    }()

    public static let isIphoneX: Bool = {
        isIphoneXSeries
    }()

    public static let isIphoneXMax: Bool = {
        device.isOneOf([.iPhoneXSMax, .simulator(.iPhoneXSMax),
                        .iPhone11ProMax, .simulator(.iPhone11ProMax)])
    }()

    public static let isIphoneXR: Bool = {
        device.isOneOf([.iPhoneXR, .simulator(.iPhoneXR),
                        .iPhone11, .simulator(.iPhone11)])
    }()

    public static let isSupportFaceID: Bool = {
        let realDevices = Device.allFaceIDCapableDevices
        let simulators: [Device] = realDevices.map { .simulator($0) }

        return device.isOneOf(realDevices + simulators)
    }()

    public static var isIOS13orGreater: Bool {
        if #available(iOS 13, *) {
            return true
        } else {
            return false
        }
    }
}
