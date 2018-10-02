//
//  AssetViewHistoryCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 21/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

fileprivate enum Constants {
    static let padding: CGFloat = 14
}

final class AssetViewHistoryCell: UITableViewCell, NibReusable {
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        button.setTitle(Localizable.Asset.Cell.viewHistory, for: .normal)
        button.isUserInteractionEnabled = false
        viewContainer.addTableCellShadowStyle()
    }

    class func cellHeight() -> CGFloat {
        return 56
    }
}

final class AssetViewHistoryButton: UIButton {


    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {

        let iconSize = super.imageRect(forContentRect: contentRect).size

        return CGRect(x: contentRect.size.width - iconSize.width - Constants.padding,
                      y: ((contentRect.height - iconSize.height) * 0.5),
                      width: iconSize.width,
                      height: iconSize.height)
    }

    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {

        let titleSize = super.titleRect(forContentRect: contentRect).size

        return CGRect(x: 14,
                      y: (contentRect.height - titleSize.height) * 0.5,
                      width: titleSize.width,
                      height: titleSize.height)
    }
}
