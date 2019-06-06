//
//  CustomNavigationBar.swift
//  testApp
//
//  Created by Pavel Gubin on 5/28/19.
//  Copyright © 2019 Pavel Gubin. All rights reserved.
//

import UIKit

#warning("После перехода на экран AssetDetailsViewController появляеться баг что при push / scrollToTop не закрашиваеться верхняя область, заметно не сильно")

final class CustomNavigationBar: UINavigationBar {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let view = subviews.first {
            if let color = backgroundColor {
                view.alpha = 1
                view.backgroundColor = color
            }
            
            if let effectView = view.subviews.last as? UIVisualEffectView {
                effectView.isHidden = backgroundColor != nil
            }
        
        }
    }

}
