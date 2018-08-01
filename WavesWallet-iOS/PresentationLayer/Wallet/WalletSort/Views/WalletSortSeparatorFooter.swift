//
//  WalletSortSeparatorCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 24.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 26
}

final class WalletSortSeparatorFooter: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet var separatorView: SeparatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundView = {
            let view = UIView()
            view.backgroundColor = UIColor.basic50
            return view
        }()
        separatorView.lineColor = UIColor.accent100
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}
