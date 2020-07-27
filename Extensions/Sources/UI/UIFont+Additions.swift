//
//  UIFont+Additions.swift
//  Waves app / iOS
//
//  Generated on Zeplin. (12.07.2018).
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

import UIKit

public extension UIFont {
    ///
    static var passcodeRegular: UIFont {
        UIFont.systemFont(ofSize: 36, weight: .regular)
    }
    
    ///
    static var titleH1: UIFont {
        if Platform.isSmallDevices {
            return UIFont.systemFont(ofSize: 34.0, weight: .bold)
        } else {
            return UIFont.systemFont(ofSize: 30.0, weight: .bold)
        }
    }

    ///
    static var titleH2: UIFont {
        UIFont.systemFont(ofSize: 22.0, weight: .bold)
    }

    ///
    static var headlineRegular: UIFont {
        UIFont.systemFont(ofSize: 22.0, weight: .regular)
    }
    
    ///
    static var actionSheetRegular: UIFont {
        UIFont.systemFont(ofSize: 20.0, weight: .regular)
    }
    
    ///
    static var actionSheetSemibold: UIFont {
        UIFont.systemFont(ofSize: 20.0, weight: .semibold)
    }

    ///
    static var headlineSemibold: UIFont {
        UIFont.systemFont(ofSize: 17.0, weight: .semibold)
    }

    ///
    static var bodyRegular: UIFont {
        if Platform.isSmallDevices {
            return UIFont.systemFont(ofSize: 17.0, weight: .regular)
        } else {
            return UIFont.systemFont(ofSize: 13.0, weight: .regular)
        }
    }

    ///
    static var bodySemibold: UIFont {
        UIFont.systemFont(ofSize: 17.0, weight: .semibold)
    }
    
    /// SFProText-Semibold 16 size
    static var calloutSemibold: UIFont {
        UIFont.systemFont(ofSize: 16, weight: .semibold)
    }

    /// SFProText-Regular 13 size
    static var captionRegular: UIFont {
        UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    /// SFProText-Semibold 13 size
    static var captionSemibold: UIFont {
        UIFont.systemFont(ofSize: 13, weight: .semibold)
    }
    
    /// SFProText-Regular 12 size
    static var caption2Regular: UIFont {
        UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    /// SFProText-Semibold 12 size
    static var caption2Semibold: UIFont {
        UIFont.systemFont(ofSize: 12, weight: .semibold)
    }

    ///
    static var tagRegular: UIFont {
        UIFont.systemFont(ofSize: 10, weight: .regular)
    }

    ///
    static var tabBarRegular: UIFont {
        UIFont.systemFont(ofSize: 10, weight: .regular)
    }
    
    static func robotoRegular(size: CGFloat) -> UIFont {
        UIFont(name: "RobotoCondensed-Regular", size: size)!
    }
}
