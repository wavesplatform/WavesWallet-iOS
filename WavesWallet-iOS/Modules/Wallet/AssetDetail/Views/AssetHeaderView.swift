//
//  AssetHeaderView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 17.08.2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import UIKit
import UITools

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

    class func viewHeight(model _: AssetHeaderView.Model, width _: CGFloat) -> CGFloat {
        return 48
    }
}

// MARK: ViewConfiguration

extension AssetHeaderView: ViewConfiguration {
    func update(with model: String) {
        labelTitle.text = model
    }
}
