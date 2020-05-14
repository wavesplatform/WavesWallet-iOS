//
//  ChouseAccountCell.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import MGSwipeTableCell
import UIKit
import UITools

final class ChooseAccountCell: MGSwipeTableCell, NibReusable {
    struct Model {
        let title: String
        let address: String
        let image: UIImage?
    }

    @IBOutlet private weak var containerView: UIView!

    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelAddress: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.addTableCellShadowStyle()
        containerView.cornerRadius = 2
    }
}

extension ChooseAccountCell: ViewConfiguration {
    func update(with model: ChooseAccountCell.Model) {
        labelTitle.text = model.title
        labelAddress.text = model.address
        imageIcon.image = model.image
    }
}
