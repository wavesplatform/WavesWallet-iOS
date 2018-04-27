//
//  WalletHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class WalletHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var buttonTap: UIButton!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var iconArrow: UIImageView!
    
    override var reuseIdentifier: String? {
        return WalletHeaderView.identifier()
    }

    class func identifier() -> String  {
        return "WalletHeaderView"
    }
    
    func setupArrow(isOpenHideenAsset: Bool, animation: Bool) {
        
        let transform = isOpenHideenAsset ? CGAffineTransform(rotationAngle: CGFloat.pi) : CGAffineTransform.identity
        
        if animation {
            UIView.animate(withDuration: 0.3) {
                self.iconArrow.transform = transform
            }
        }
        else {
            iconArrow.transform = transform
        }
    }
}
