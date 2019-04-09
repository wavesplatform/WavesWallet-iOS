import UIKit
import DeviceKit

struct Platform {

    static let ScreenWidth = UIScreen.main.bounds.width

    private static let device = Device()

    static let isIphone5: Bool = {
        return device.isOneOf([.iPhone5, .simulator(.iPhone5),
                               .iPhone5c, .simulator(.iPhone5c),
                               .iPhone5s, .simulator(.iPhone5s),
                               .iPhoneSE, .simulator(.iPhoneSE)])
    }()

    static let isIphone7: Bool = {

        return device.isOneOf([.iPhone6, .simulator(.iPhone6),
                               .iPhone6s, .simulator(.iPhone6s),
                               .iPhone7, .simulator(.iPhone7),
                               .iPhone8, .simulator(.iPhone8)])
    }()

    static let isIphoneXSeries: Bool = {
        return device.isOneOf([.iPhoneX, .simulator(.iPhoneX),
                               .iPhoneXr, .simulator(.iPhoneXr),
                               .iPhoneXs, .simulator(.iPhoneXs),
                               .iPhoneXsMax, .simulator(.iPhoneXsMax)])
    }()

    static let isSupportFaceID: Bool = {

        let realDevices = Device.allFaceIDCapableDevices
        let simulators: [Device] = realDevices.map {.simulator($0)}

        return device.isOneOf(realDevices + simulators)
    }()
}
