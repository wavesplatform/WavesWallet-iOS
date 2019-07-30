//
//  WidgetSettingsAssetCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 29.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import DomainLayer

private enum Constants {
    static let movedRowAlpha: CGFloat = 0.9
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionStyle = .none
        backgroundColor = .basic50
        contentView.backgroundColor = .basic50
        containerView.addTableCellShadowStyle()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if alpha <= Constants.movedRowAlpha {
            containerView.removeShadow()
        } else {
            containerView.addTableCellShadowStyle()
        }
    }
}

// MARK: ViewConfiguration

extension WidgetSettingsAssetCell: ViewConfiguration {
    
    func update(with model: Model) {
        
        nameLabel.text = model.asset.displayName
        iconImageContainerView.isHidden = model.isLock == false
    }
}
