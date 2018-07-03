//
//  AssetChartHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/8/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class AssetChartHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonChangePeriod: UIButton!
    
    override var reuseIdentifier: String? {
        return AssetChartHeaderView.identifier()
    }
    
    class func identifier() -> String  {
        return "AssetChartHeaderView"
    }
    
    class func viewHeight() -> CGFloat {
        return 34
    }

}
