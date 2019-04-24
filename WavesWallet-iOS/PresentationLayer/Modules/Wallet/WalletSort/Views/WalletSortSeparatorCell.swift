//
//  WalletSortLineCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/23/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let defaultHeight: CGFloat = 26
    static let titleHeight: CGFloat = 55
}

final class WalletSortSeparatorCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var viewLine: SeparatorView!
    @IBOutlet private weak var labelTitle: UILabel!
    
    enum Model {
        case line
        case title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewLine.lineColor = UIColor.accent100
        labelTitle.text = Localizable.Waves.Walletsort.Label.hiddenAssets
    }
    
}

extension WalletSortSeparatorCell: ViewConfiguration {
    
    func update(with model: Model) {
        labelTitle.isHidden = model != .title
    }
}

extension WalletSortSeparatorCell: ViewCalculateHeight {
    
    static func viewHeight(model: Model, width: CGFloat) -> CGFloat {
        
        if model == .title {
            return Constants.titleHeight
        }
        return Constants.defaultHeight
    }
}
