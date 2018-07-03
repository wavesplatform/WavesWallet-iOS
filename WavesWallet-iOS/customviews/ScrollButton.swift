//
//  ScrollButton.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class ScrollButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(title: String) {
        
        let font = UIFont.systemFont(ofSize: 13)
        super.init(frame: CGRect(x: 0, y: 0, width: title.maxWidth(font: font) + 20, height: 30))
        
        layer.cornerRadius = 3
        setTitle(title, for: .normal)
        setTitleColor(.basic500, for: .normal)
        titleLabel?.font = font
        backgroundColor = .basic100
    }
}
