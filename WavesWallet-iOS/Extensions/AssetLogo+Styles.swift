//
//  AssetLogo+Styles.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 09.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import Extensions

extension AssetLogo.Style {
        
    static var litle: AssetLogo.Style = {
        return AssetLogo.Style.init(size: CGSize(width: 24, height: 24),
                                    font: UIFont.systemFont(ofSize: 15),
                                    specs: .init(sponsoredImage: Images.sponsoritem18White.image,
                                                 scriptImage: Images.scriptasset18White.image,
                                                 size: CGSize(width: 10,
                                                              height: 10)))
    }()
    
    static var medium: AssetLogo.Style = {
        return AssetLogo.Style.init(size: CGSize(width: 28, height: 28),
                                    font: UIFont.systemFont(ofSize: 15),
                                    specs: .init(sponsoredImage: Images.sponsoritem18White.image,
                                                 scriptImage: Images.scriptasset18White.image,
                                                 size: CGSize(width: 12, height: 12)))
    }()
    
    static var large: AssetLogo.Style = {
        return AssetLogo.Style.init(size: CGSize(width: 48, height: 48),
                                    font: UIFont.systemFont(ofSize: 15),
                                    specs: .init(sponsoredImage: Images.sponsoritem18White.image,
                                                 scriptImage: Images.scriptasset18White.image,
                                                 size: CGSize(width: 18, height: 18)))
    }()
}
