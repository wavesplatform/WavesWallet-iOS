import UIKit
import Device_swift

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
