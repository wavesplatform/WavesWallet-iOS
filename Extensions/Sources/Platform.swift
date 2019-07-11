import UIKit
import DeviceKit

//TODO: Rename
public struct Platform {

    public static let ScreenWidth = UIScreen.main.bounds.width

    private static let device = Device.current

    public static let isIphone5: Bool = {
        return device.isOneOf([.iPhone5, .simulator(.iPhone5),
                               .iPhone5c, .simulator(.iPhone5c),
                               .iPhone5s, .simulator(.iPhone5s),
                               .iPhoneSE, .simulator(.iPhoneSE)])
    }()

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
                               .iPhoneXSMax, .simulator(.iPhoneXSMax)])
    }()
        
    public static let isIphonePlus: Bool = {
        
        return device.isOneOf([.iPhone6Plus, .simulator(.iPhone6Plus),
                               .iPhone6sPlus, .simulator(.iPhone6sPlus),
                               .iPhone7Plus, .simulator(.iPhone7Plus),
                               .iPhone8Plus, .simulator(.iPhone8Plus)])
    }()
    
    public static let isIphoneX: Bool = {
        
        return device.isOneOf([.iPhoneX, .simulator(.iPhoneX),
                               .iPhoneXS, .simulator(.iPhoneXS)])
    }()
    
    public static let isIphoneXMax: Bool = {
        
        return device.isOneOf([.iPhoneXSMax, .simulator(.iPhoneXSMax)])
    }()
    
    public static let isIphoneXR: Bool = {
        
        return device.isOneOf([.iPhoneXR, .simulator(.iPhoneXR)])
    }()
    
    public static let isSupportFaceID: Bool = {

        let realDevices = Device.allFaceIDCapableDevices
        let simulators: [Device] = realDevices.map {.simulator($0)}

        return device.isOneOf(realDevices + simulators)
    }()
}
