//
//  NewWalletSortCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/23/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

fileprivate enum Constants {
    static let height: CGFloat = 56
    static let icon: CGSize = CGSize(width: 28, height: 28)
    static let sponsoredIcon = CGSize(width: 12, height: 12)
}

final class WalletSortCell: UITableViewCell, NibReusable {
    @IBOutlet private var buttonFav: UIButton!
    @IBOutlet private var imageIcon: UIImageView!
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var switchControl: UISwitch!
    @IBOutlet private var viewContent: UIView!
    
    private var isDragging: Bool = false
    
    private var disposeBag = DisposeBag()
    private var assetType = AssetType.list
    
    var changedValueSwitchControl: (() -> Void)?
    var favouriteButtonTapped:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionStyle = .none
        backgroundColor = .basic50
        contentView.backgroundColor = .basic50
        viewContent.addTableCellShadowStyle()
        switchControl.addTarget(self, action: #selector(changedValueSwitchAction), for: .valueChanged)
        buttonFav.addTarget(self, action: #selector(favouriteTapped), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageIcon.image = nil
        disposeBag = DisposeBag()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if alpha <= 0.9 && !isDragging {
            isDragging = true
            beginMove()
        }
        
        if alpha <= 0.9 && isDragging {
            isDragging = false
            endMove()
        }
    }
    
    @objc private func favouriteTapped() {
        
        favouriteButtonTapped?()
        ImpactFeedbackGenerator.impactOccurred()
    }
    
    @objc private func changedValueSwitchAction() {
        changedValueSwitchControl?()
    
    }
}

extension WalletSortCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}

private extension WalletSortCell {
    func beginMove() {
        viewContent.removeShadow()
    }
    
    func endMove() {
        updateBackground()
    }
    
    func updateBackground() {
        if assetType == .favourite || assetType == .hidden {
            viewContent.backgroundColor = .clear
            viewContent.removeShadow()
        } else {
            viewContent.backgroundColor = .white
            viewContent.addTableCellShadowStyle()
        }
    }
}

// MARK: ViewConfiguration
extension WalletSortCell: ViewConfiguration {
    
    enum AssetType {
        case favourite
        case list
        case hidden
    }
    
    struct Model {
        let name: String
        let isMyWavesToken: Bool
        let isVisibility: Bool
        let isHidden: Bool
        let isFavorite: Bool
        let isGateway: Bool
        let icon: DomainLayer.DTO.Asset.Icon
        let isSponsored: Bool
        let hasScript: Bool
        let type: AssetType
    }
    
    func update(with model: Model) {
        
        let image = model.isFavorite ? Images.favorite14Submit300.image : Images.iconFavEmpty.image
        buttonFav.setImage(image , for: .normal)
        labelTitle.attributedText = NSAttributedString.styleForMyAssetName(assetName: model.name,
                                                                           isMyAsset: model.isMyWavesToken)
        switchControl.isHidden = !model.isVisibility
        switchControl.isOn = !model.isHidden
        assetType = model.type
        updateBackground()
        
        AssetLogo.logo(icon: model.icon,
                       style: AssetLogo.Style(size: Constants.icon,
                                              font: UIFont.systemFont(ofSize: 15),
                                              specs: .init(isSponsored: model.isSponsored,
                                                           hasScript: model.hasScript,
                                                           size: Constants.sponsoredIcon)))
            .observeOn(MainScheduler.instance)
            .bind(to: imageIcon.rx.image)
            .disposed(by: disposeBag)
    }
}
