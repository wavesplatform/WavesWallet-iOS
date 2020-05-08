//
//  UIFont+Additions.swift
//  Waves app / iOS
//
//  Generated on Zeplin. (12.07.2018).
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

import UIKit

public extension UIFont {
    static var titleH1: UIFont {
        UIFont.systemFont(ofSize: 34.0, weight: .bold)
    }

    static var titleH2: UIFont {
        UIFont.systemFont(ofSize: 22.0, weight: .bold)
    }

    static var headlineRegular: UIFont {
        UIFont.systemFont(ofSize: 22.0, weight: .regular)
    }

    static var headlineSemibold: UIFont {
        UIFont.systemFont(ofSize: 17.0, weight: .semibold)
    }

    static var bodyRegular: UIFont {
        UIFont.systemFont(ofSize: 17.0, weight: .regular)
    }

    static var bodySemibold: UIFont {
        UIFont.systemFont(ofSize: 17.0, weight: .semibold)
    }

    static var actionSheetRegular: UIFont {
        UIFont.systemFont(ofSize: 20.0, weight: .regular)
    }

    static var actionSheetSemibold: UIFont {
        UIFont.systemFont(ofSize: 20.0, weight: .semibold)
    }

    static var passcodeRegular: UIFont {
        UIFont.systemFont(ofSize: 36, weight: .regular)
    }

    static var captionRegular: UIFont {
        UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    static var captionSemibold: UIFont {
        UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    static var tagRegular: UIFont {
        UIFont.systemFont(ofSize: 10, weight: .regular)
    }

    static var tabBarRegular: UIFont {
        UIFont.systemFont(ofSize: 10, weight: .regular)
    }
    
    static func robotoRegular(size: CGFloat) -> UIFont {
        UIFont(name: "RobotoCondensed-Regular", size: size)!
    }
}
