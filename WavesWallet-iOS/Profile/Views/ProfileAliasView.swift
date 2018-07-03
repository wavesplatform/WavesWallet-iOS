//
//  ProfileAliasView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class ProfileAliasView: UIView {

    
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var buttonCopy: UIButton!
    
    func setup(title: String) {
        
        labelTitle.text = title
        frame.size.width = title.maxWidth(font: labelTitle.font) + 14 + 46
    }
}
