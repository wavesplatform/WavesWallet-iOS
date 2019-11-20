//
//  HistoryHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Mac on 16/08/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import Extensions

final class HistoryHeaderView: UITableViewHeaderFooterView, NibReusable {
    @IBOutlet private var labelTitle: UILabel!
    
    class func viewHeight() -> CGFloat {
        return 36
    }
}

// MARK: ViewConfiguration

extension HistoryHeaderView: ViewConfiguration {
    func update(with model: String) {
        labelTitle.text = model
    }
}
