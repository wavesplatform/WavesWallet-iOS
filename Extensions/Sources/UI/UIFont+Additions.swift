//
//  UIFont+Additions.swift
//  Waves app / iOS
//
//  Generated on Zeplin. (12.07.2018).
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

import UIKit

public extension UIFont {

    public class var titleH1: UIFont {
        return UIFont.systemFont(ofSize: 34.0, weight: .bold)
    }

    public class var titleH2: UIFont {
        return UIFont.systemFont(ofSize: 22.0, weight: .bold)
    }

    public class var headlineRegular: UIFont {
        return UIFont.systemFont(ofSize: 22.0, weight: .regular)
    }

    public class var headlineSemibold: UIFont {
        return UIFont.systemFont(ofSize: 17.0, weight: .semibold)
    }

    public class var bodyRegular: UIFont {
        return UIFont.systemFont(ofSize: 17.0, weight: .regular)
    }

    public class var bodySemibold: UIFont {
        return UIFont.systemFont(ofSize: 17.0, weight: .semibold)
    }

    public class var actionSheetRegular: UIFont {
        return UIFont.systemFont(ofSize: 20.0, weight: .regular)
    }

    public class var actionSheetSemibold: UIFont {
        return UIFont.systemFont(ofSize: 20.0, weight: .semibold)
    }

    public class var passcodeRegular: UIFont {
        return UIFont.systemFont(ofSize: 36, weight: .regular)
    }

    public class var captionRegular: UIFont {
        return UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    public class var captionSemibold: UIFont {
        return UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    public class var tagRegular: UIFont {
        return UIFont.systemFont(ofSize: 10, weight: .regular)
    }

    public class var tabBarRegular: UIFont {
        return UIFont.systemFont(ofSize: 10, weight: .regular)
    }
    
    class func robotoRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "RobotoCondensed-Regular", size: size)!
    }
}
