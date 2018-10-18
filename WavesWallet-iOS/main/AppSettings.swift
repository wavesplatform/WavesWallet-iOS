import UIKit

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

enum HistoryTransactionState: Int {
    case viewReceived = 0
    case viewSend
    case viewLeasing
    case exchange // not show comment, not show address
    case selfTranserred // not show address
    case tokenGeneration // show ID token
    case tokenReissue // show ID token,
    case tokenBurning // show ID token, do not have bottom state of token
    case createdAlias // show ID token
    case canceledLeasing
    case incomingLeasing
    case massSend // multiple addresses
    case massReceived
}

let HistoryTransactionImages = ["asset_receive", "tSend48", "wallet_start_lease", "tExchange48", "tSelftrans48", "tTokengen48", "tTokenreis48", "tTokenburn48", "tAlias48", "tCloselease48", "tIncominglease48", "tMasstransfer48", "tMassreceived48"]


struct Platform {

    static let ScreenWidth = UIScreen.main.bounds.size.width
    
    static let isIphoneX : Bool = {
        return UIScreen.main.bounds.size.width == 375 && UIScreen.main.bounds.size.height == 812 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }()
    
    static let isIphone5 : Bool = {
        return UIScreen.main.bounds.size.width == 320 && UIScreen.main.bounds.size.height == 568 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }()
    
    static let isIphonePlus : Bool = {
        return UIScreen.main.bounds.size.width == 414 && UIScreen.main.bounds.size.height == 736 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }()
    
    static let isIphone7 : Bool = {
        return UIScreen.main.bounds.size.width == 375 && UIScreen.main.bounds.size.height == 667 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }()
    
    static let isIphoneXMax : Bool = {
        return UIScreen.main.bounds.size.width == 414 && UIScreen.main.bounds.size.height == 896 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone && UIScreen.main.scale == 3
    }()
    
    static let isIphoneXR : Bool = {
        return UIScreen.main.bounds.size.width == 414 && UIScreen.main.bounds.size.height == 896 && UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone && UIScreen.main.scale == 2
    }()
    
}
