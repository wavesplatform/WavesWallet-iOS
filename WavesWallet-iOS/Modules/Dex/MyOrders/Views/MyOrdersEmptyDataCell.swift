//
//  MyOrdersEmptyDataCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 25.12.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Extensions
import UIKit
import UITools

private enum Constants {
    static let containerHeight: CGFloat = 130
}

final class MyOrdersEmptyDataCell: UITableViewCell, NibReusable {
    @IBOutlet private weak var labelDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        labelDescription.text = Localizable.Waves.Dexmyorders.Label.emptyData
    }
}

extension MyOrdersEmptyDataCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.containerHeight
    }
}
