//
//  HistoryHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Mac on 16/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class HistoryHeaderView: UITableViewHeaderFooterView, NibReusable {
    @IBOutlet var labelTitle: UILabel!
    
    class func viewHeight() -> CGFloat {
        return 48
    }
}

// MARK: ViewConfiguration

extension HistoryHeaderView: ViewConfiguration {
    func update(with model: String) {
        labelTitle.text = model
    }
}
