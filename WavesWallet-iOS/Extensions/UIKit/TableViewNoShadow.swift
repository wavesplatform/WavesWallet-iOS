//
//  TableViewNoShadow.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

final class TableViewNoShadow: UITableView {
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if "\(type(of: subview))" == "UIShadowView" {
            subview.removeFromSuperview()
        }
    }
}
