//
//  LastTraderHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 06.08.17.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class LastTraderHeaderView: UITableViewHeaderFooterView {

    class func viewHeight() -> CGFloat {
        return 30
    }
    
    override var reuseIdentifier: String? {
        return LastTraderHeaderView.getIdentifier()
    }
    
    static func getIdentifier() -> String {
        return "LastTraderHeaderView"
    }
}
