//
//  UIColor.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 30.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

extension UIColor {

    static func colorAsset(name: String) -> UIColor {

        guard let symbol = name.lowercased().first else {
            return UIColor(150, 188, 160)
        }

        let name = String(symbol)
        
        if name == "a" { return UIColor(56, 161, 45) }
        else if name == "b" { return UIColor(105, 114, 123) }
        else if name == "c" { return UIColor(228, 149, 22) }
        else if name == "d" { return UIColor(0, 140, 167) }
        else if name == "e" { return UIColor(255, 91, 56) }
        else if name == "f" { return UIColor(255, 106, 0) }
        else if name == "g" { return UIColor(199, 65, 36) }
        else if name == "h" { return UIColor(0, 167, 142) }
        else if name == "i" { return UIColor(176, 30, 83) }
        else if name == "j" { return UIColor(224, 198, 27) }
        else if name == "k" { return UIColor(90, 129, 234) }
        else if name == "l" { return UIColor(114, 183, 210) }
        else if name == "m" { return UIColor(165, 181, 195) }
        else if name == "n" { return UIColor(129, 201, 38) }
        else if name == "o" { return UIColor(134, 163, 189) }
        else if name == "p" { return UIColor(193, 216, 47) }
        else if name == "q" { return UIColor(92, 132, 168) }
        else if name == "r" { return UIColor(38, 126, 27) }
        else if name == "s" { return UIColor(252, 176, 52) }
        else if name == "t" { return UIColor(255, 132, 106) }
        else if name == "u" { return UIColor(71, 193, 255) }
        else if name == "v" { return UIColor(0, 160, 175) }
        else if name == "w" { return UIColor(133, 215, 198) }
        else if name == "x" { return UIColor(138, 121, 103) }
        else if name == "y" { return UIColor(38, 193, 201) }
        else if name == "z" { return UIColor(114, 210, 139) }

        return UIColor(150, 188, 160)
    }
}
