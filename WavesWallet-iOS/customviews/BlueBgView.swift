//
//  BlueBgView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/19/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import DeviceKit

final class BlueBgView: UIView {

    override func draw(_ rect: CGRect) {
        
        var image: UIImage?
        if Platform.isIphone5 {
            image = UIImage(named: "bg-iphone5")
        }
        else if Platform.isIphonePlus {
            image = UIImage(named: "bg-iphone8plus")
        }
        else if Platform.isIphoneX {
            image = UIImage(named: "bg-iphonex")
        }
        else if Platform.isIphoneXR {
            image = UIImage(named: "bg-iphonexr")
        }
        else if Platform.isIphoneXMax {
            image = UIImage(named: "bg-iphonexsmax")
        }
        else {
            image = UIImage(named: "bg-iphone8")
        }
        image?.draw(in: UIScreen.main.bounds)
    }
}

fileprivate extension Platform {
    
    private static let device = Device()
    
    static let isIphoneX: Bool = {
        
        return device.isOneOf([.iPhoneX, .simulator(.iPhoneX),
                               .iPhoneXs, .simulator(.iPhoneXs)])
    }()
    
    static let isIphoneXMax: Bool = {
        
        return device.isOneOf([.iPhoneXsMax, .simulator(.iPhoneXsMax)])
    }()
    
    static let isIphoneXR: Bool = {
        
        return device.isOneOf([.iPhoneXr, .simulator(.iPhoneXr)])
    }()
}
