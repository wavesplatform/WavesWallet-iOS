//
//  MyOrderHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 31.08.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class MyOrderHeaderView: UITableViewHeaderFooterView {

    override var reuseIdentifier: String? {
        return MyOrderHeaderView.getIdentifier()
    }
    
    static func getIdentifier() -> String {
        return "MyOrderHeaderView"
    }
}
