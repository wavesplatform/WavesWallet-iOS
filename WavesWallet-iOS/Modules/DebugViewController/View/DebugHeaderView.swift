//
//  DebugHeaderView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 22.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 44
}

final class DebugHeaderView: UITableViewHeaderFooterView, NibReusable {
    
    @IBOutlet private var labelTitle: UILabel!
    
    class func viewHeight() -> CGFloat {
        return Constants.height
    }
}

// MARK: ViewConfiguration

extension DebugHeaderView: ViewConfiguration {
    func update(with model: String) {
        labelTitle.text = model
    }
}

