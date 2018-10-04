//
//  ProfileTableCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 03/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class ProfileValueCell: UITableViewCell, Reusable {

    struct Model {
        let title: String
    }

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var containerView: UIView!    
    @IBOutlet private weak var iconArrow: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
//        containerView.addTableCellShadowStyle()

        containerView.setupShadow(options: .init(offset: CGSize(width: 0, height: 4),
                                    color: .black,
                                   opacity: 0.15,
                                   shadowRadius: 4,
                                   cornerRadius: 2,
                                   shouldRasterize: true))
        contentView.backgroundColor = .clear
    }

    class func cellHeight() -> CGFloat {
        return 56
    }
}

// MARK: ViewConfiguration

extension ProfileValueCell: ViewConfiguration {

    func update(with model: ProfileValueCell.Model) {
        labelTitle.text = model.title
    }
}
