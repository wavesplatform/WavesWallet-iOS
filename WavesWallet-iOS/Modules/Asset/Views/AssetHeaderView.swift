//
//  AssetHeaderView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 17.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class AssetHeaderView: UITableViewHeaderFooterView, NibReusable, ViewCalculateHeight {

    @IBOutlet private var labelTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundView = {
            let view = UIView()
            view.backgroundColor = .basic50
            return view
        }()
    }

    class func viewHeight(model: AssetHeaderView.Model, width: CGFloat) -> CGFloat {
        return 48
    }
}

// MARK: ViewConfiguration

extension AssetHeaderView: ViewConfiguration {
    func update(with model: String) {
        labelTitle.text = model
    }
}
