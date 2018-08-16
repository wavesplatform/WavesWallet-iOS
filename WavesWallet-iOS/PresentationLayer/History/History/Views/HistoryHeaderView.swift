//
//  HistoryHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Mac on 16/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class HistoryHeaderView: UITableViewHeaderFooterView, NibReusable {
    @IBOutlet var buttonTap: UIButton!
    @IBOutlet var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonTap.addTarget(self, action: #selector(tapHandler), for: .touchUpInside)
    }

    
    @objc private func tapHandler() {
    }
    
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
