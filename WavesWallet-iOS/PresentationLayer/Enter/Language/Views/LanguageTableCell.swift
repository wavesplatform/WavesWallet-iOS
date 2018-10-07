//
//  LanguageTableCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 07/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class LanguageTableCell: UITableViewCell, NibReusable {
    
    struct Model {
        let icon: UIImage?
        let title: String
        let isOn: Bool
    }
    
    @IBOutlet fileprivate weak var iconLanguage: UIImageView!
    @IBOutlet fileprivate weak var labelTitle: UILabel!
    @IBOutlet fileprivate weak var iconCheckmark: UIImageView!
    
    class func cellHeight() -> CGFloat {
        return 60
    }
    
}

extension LanguageTableCell: ViewConfiguration {
    
    func update(with model: LanguageTableCell.Model) {
        iconLanguage.image = model.icon
        labelTitle.text = model.title
        
        if model.isOn {
            iconCheckmark.image = Images.on.image
        } else {
            iconCheckmark.image = Images.off.image
        }
    }
    
}
