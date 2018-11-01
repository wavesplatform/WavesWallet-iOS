import UIKit
import Device_swift

class AppColors {
    static let wavesColor = UIColor(netHex: 0x003597)//UIColor(netHex: 0x4b7190)
    static let darkPrimaryColor = UIColor(netHex: 0x003597)//UIColor(netHex: 0x4b7190)
    static let mainBgColor = UIColor.white
    static let darkBgColor = UIColor(netHex: 0xedf0f4)
    static let activeColor = UIColor(netHex: 0x1f5af6)
    static let inactiveColor = UIColor(netHex: 0xc4d0ef)
    static let greyBorderColor = UIColor(netHex: 0xc7c9cc)
    static let lightSectionColor = UIColor(netHex: 0xf6f7f8)
    static let sectionColor = UIColor(netHex: 0xeaecee)
    static let sendRed = UIColor(netHex: 0xe27e82)
    static let receiveGreen = UIColor(netHex: 0x85b45b)
    static let accentColor = UIColor(netHex: 0x1f5af6)
    static let lightGreyText = UIColor(netHex: 0xc2c5ce)
    static let greyText = UIColor(netHex: 0x9299a2)
    static let darkGreyText = UIColor(netHex: 0x3B3B3B)
    static let dexNavBarColor = UIColor(netHex: 0x2a2a2a)
    
    static let dexBuyColor = UIColor(netHex: 0x58a763)
    static let dexLightBuyColor = UIColor(netHex: 0x77bf82)
    static let dexSellColor = UIColor(netHex: 0xe66a67)
    static let dexLightSellColor = UIColor(netHex: 0xe97c79)
}

struct Platform {

    static let ScreenWidth = UIScreen.main.bounds.width
    
    static let deviceType = UIDevice.current.deviceType
    
    static let isIphone5 : Bool = {
        switch Platform.deviceType {
        case .simulator:
            return UIScreen.main.bounds.size.width == 320 && UIScreen.main.bounds.size.height == 568 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
        case .iPhone5, .iPhoneSE, .iPhone5C, .iPhone5S:
            return true
        default:
            return false
        }
    }()
    
    static let isIphone7 : Bool = {
        switch Platform.deviceType {
        case .simulator:
            return UIScreen.main.bounds.size.width == 375 && UIScreen.main.bounds.size.height == 667 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
        case .iPhone6, .iPhone6S, .iPhone7, .iPhone8:
            return true
        default:
            return false
        }
    }()
    
    static let isIphonePlus : Bool = {
        switch Platform.deviceType {
        case .simulator:
        return UIScreen.main.bounds.size.width == 414 && UIScreen.main.bounds.size.height == 736 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
        case .iPhone6Plus, .iPhone6SPlus, .iPhone7Plus, .iPhone8Plus:
            return true
        default:
            return false
        }
    }()
    
    static let isIphoneX : Bool = {
        switch Platform.deviceType {
        case .simulator:
            return UIScreen.main.bounds.size.width == 375 && UIScreen.main.bounds.size.height == 812 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
        case .iPhoneX, .iPhoneXS:
            return true
        default:
            return false
        }
    }()
    
    static let isIphoneXMax : Bool = {
        switch Platform.deviceType {
        case .simulator:
            return UIScreen.main.bounds.size.width == 414 && UIScreen.main.bounds.size.height == 896 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone && UIScreen.main.scale == 3
        case .iPhoneXSMax:
            return true
        default:
            return false
        }
    }()
    
    static let isIphoneXR : Bool = {
        switch Platform.deviceType {
        case .simulator:
            return UIScreen.main.bounds.size.width == 414 && UIScreen.main.bounds.size.height == 896 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone && UIScreen.main.scale == 2
        case .iPhoneXR:
            return true
        default:
            return false
        }
    }()
    
}
