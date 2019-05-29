//
//  CustomNavigationBar.swift
//  testApp
//
//  Created by Pavel Gubin on 5/28/19.
//  Copyright © 2019 Pavel Gubin. All rights reserved.
//

import UIKit

final class CustomNavigationBar: UINavigationBar {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let view = subviews.first {
            if let visualEffectView = view.subviews.last as? UIVisualEffectView {
                if let color = backgroundColor {
                    visualEffectView.subviews.last?.backgroundColor = color
                }
            }
        }
    }

}
