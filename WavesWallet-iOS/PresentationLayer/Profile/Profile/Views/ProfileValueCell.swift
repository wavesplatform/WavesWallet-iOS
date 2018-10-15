//
//  ProfileTableCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 03/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 56
}

final class ProfileValueCell: UITableViewCell, Reusable {

    struct Model {
        let title: String
    }

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var containerView: UIView!    
    @IBOutlet private weak var iconArrow: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.addTableCellShadowStyle()        
    }

    class func cellHeight() -> CGFloat {
        return Constants.height
    }
}

// MARK: ViewConfiguration

extension ProfileValueCell: ViewConfiguration {

    func update(with model: ProfileValueCell.Model) {
        labelTitle.text = model.title
    }
}
