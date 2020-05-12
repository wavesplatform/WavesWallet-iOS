//
//  WidgetSettingsAssetCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 29.07.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift
import UIKit
import UITools

private enum Constants {
    static let movedRowAlpha: CGFloat = 0.9
    static let shadowOffSet: CGSize = CGSize(width: 0, height: 2)
}

final class WidgetSettingsAssetCell: UITableViewCell, Reusable {
    struct Model {
        let asset: DomainLayer.DTO.Asset
        let isLock: Bool
    }

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var iconImageView: UIImageView!
    @IBOutlet private var iconImageContainerView: UIView!
    @IBOutlet private weak var viewDelete: UIView!

    var deleteAction: ((UITableViewCell) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionStyle = .none

        containerView.addTableCellShadowStyle(offset: Constants.shadowOffSet)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if alpha <= Constants.movedRowAlpha {
            containerView.backgroundColor = .white
            containerView.addTableCellShadowStyle(offset: Constants.shadowOffSet)
        }
    }

    @IBAction private func deleteTapped(_: Any) {
        deleteAction?(self)
    }
}

// MARK: ViewConfiguration

extension WidgetSettingsAssetCell: ViewConfiguration {
    func update(with model: Model) {
        nameLabel.text = model.asset.ticker ?? model.asset.displayName
        iconImageContainerView.isHidden = model.isLock == false
        viewDelete.isHidden = model.isLock == true
    }
}
