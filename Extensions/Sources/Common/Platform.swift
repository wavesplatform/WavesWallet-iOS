import UIKit
import DeviceKit

public extension Platform {
        
    enum Inch: Double, Equatable {
                
        case inch3_5 = 3.5
        case inch4 = 4
        case inch4_7 = 4.7
        case inch5_5 = 5.5
        
        case inch5_8 = 5.8
        case inch6_1 = 6.1
        
        case inch6_5 = 6.5
        
        case inch7_9 = 7.9
        case inch9_7 = 9.7
        case inch10_5 = 10.5
        case inch12_9 = 12.9
        
        public static var smallDevices: [Inch] {
            return [.inch3_5, .inch4, .inch4_7, .inch5_5]
        }
        
        public static var mediumDevices: [Inch] {
            return [.inch5_8, .inch6_1]
        }
        
        public static var largeDevices: [Inch] {
            return [.inch6_5]
        }
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
        return Platform.Inch.init(rawValue: device.diagonal) ?? Platform.Inch.inch4
    }

    @available(iOS, deprecated, message: "Use isSmallDevices")
    public static let isIphone5: Bool = {
        return device.isOneOf([.iPhone5, .simulator(.iPhone5),
                               .iPhone5c, .simulator(.iPhone5c),
                               .iPhone5s, .simulator(.iPhone5s),
                               .iPhoneSE, .simulator(.iPhoneSE)])
    }()

    @available(iOS, deprecated, message: "Use isMediumDevices")
    public static let isIphone7: Bool = {

        return device.isOneOf([.iPhone6, .simulator(.iPhone6),
                               .iPhone6s, .simulator(.iPhone6s),
                               .iPhone7, .simulator(.iPhone7),
                               .iPhone8, .simulator(.iPhone8)])
    }()
    
    public static let isIphoneXSeries: Bool = {
        return device.isOneOf([.iPhoneX, .simulator(.iPhoneX),
                               .iPhoneXR, .simulator(.iPhoneXR),
                               .iPhoneXS, .simulator(.iPhoneXS),
                               .iPhoneXSMax, .simulator(.iPhoneXSMax),
                               .iPhone11, .simulator(.iPhone11),
                               .iPhone11Pro, .simulator(.iPhone11Pro),
                               .iPhone11ProMax, .simulator(.iPhone11ProMax)])
    }()
        
    @available(iOS, deprecated, message: "Use isLargeDevices")
    public static let isIphonePlus: Bool = {
        
        return device.isOneOf([.iPhone6Plus, .simulator(.iPhone6Plus),
                               .iPhone6sPlus, .simulator(.iPhone6sPlus),
                               .iPhone7Plus, .simulator(.iPhone7Plus),
                               .iPhone8Plus, .simulator(.iPhone8Plus)])
    }()
    
    
    public static let isIphoneX: Bool = {
        return isIphoneXSeries
    }()
        
    public static let isIphoneXMax: Bool = {
        
        return device.isOneOf([.iPhoneXSMax, .simulator(.iPhoneXSMax),
                               .iPhone11ProMax, .simulator(.iPhone11ProMax)])
    }()
        
    public static let isIphoneXR: Bool = {
        
        return device.isOneOf([.iPhoneXR, .simulator(.iPhoneXR),
                               .iPhone11, .simulator(.iPhone11)])
    }()
    
    public static let isSupportFaceID: Bool = {

        let realDevices = Device.allFaceIDCapableDevices
        let simulators: [Device] = realDevices.map {.simulator($0)}

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
