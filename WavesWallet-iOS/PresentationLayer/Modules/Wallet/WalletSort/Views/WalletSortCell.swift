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
    static let delaySwitch: TimeInterval = 0.2
    static let animationDuration: TimeInterval = 0.3
    static let movedRowAlpha: CGFloat = 0.9
}

final class WalletSortCell: UITableViewCell, NibReusable {
    @IBOutlet private weak var buttonFav: UIButton!
    @IBOutlet private weak var imageIcon: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var switchControl: UISwitch!
    @IBOutlet private weak var viewShadow: UIView!
        
    private var disposeBag = DisposeBag()
    private var assetType = AssetType.list
    
    private var isHiddenWhiteContainer = false
    private var isMovingAnimation = false
    
    var changedValueSwitchControl: (() -> Void)?
    var favouriteButtonTapped:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionStyle = .none
        backgroundColor = .basic50
        contentView.backgroundColor = .basic50
        viewShadow.addTableCellShadowStyle()
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

        if alpha <= Constants.movedRowAlpha && !isMovingAnimation {
            updateBackground()
        }
    }
    
    @objc private func favouriteTapped() {
        
        favouriteButtonTapped?()
        ImpactFeedbackGenerator.impactOccurred()
        
        if assetType == .favourite {
            buttonFav.setImage(Images.iconFavEmpty.image , for: .normal)
        }
        else {
            buttonFav.setImage(Images.favorite14Submit300.image , for: .normal)
        }
        switchControl.setOn(true, animated: true)
        
        if assetType == .list {
            showBackgroundContentWithAnimation(isVisible: false)
        }
        else if assetType == .favourite {
            showBackgroundContentWithAnimation(isVisible: true)
        }
    }
    
    @objc private func changedValueSwitchAction() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delaySwitch) {
            self.changedValueSwitchControl?()
            
            self.buttonFav.setImage(Images.iconFavEmpty.image , for: .normal)
           
            if self.assetType == .hidden {
                self.showBackgroundContentWithAnimation(isVisible: true)
            }
            else if self.assetType == .list {
                self.showBackgroundContentWithAnimation(isVisible: false)
            }
        }
    }
    
    func showAnimationToFavoriteState() {
        isMovingAnimation = true
        buttonFav.setImage(Images.favorite14Submit300.image , for: .normal)
        showBackgroundContentWithAnimation(isVisible: false)

    }
    
    func showAnimationToHiddenState() {
        isMovingAnimation = true
        buttonFav.setImage(Images.iconFavEmpty.image , for: .normal)
        showBackgroundContentWithAnimation(isVisible: false)
    }
    
    func showAnimationToListState() {
        isMovingAnimation = true
        buttonFav.setImage(Images.iconFavEmpty.image , for: .normal)
        showBackgroundContentWithAnimation(isVisible: true)
    }
}

extension WalletSortCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}

private extension WalletSortCell {
    
    func updateBackground() {

        if assetType == .favourite || assetType == .hidden {
            viewShadow.alpha = 0
            isHiddenWhiteContainer = true

        } else {
         
            viewShadow.alpha = 1
            viewShadow.backgroundColor = .white
            viewShadow.addTableCellShadowStyle()
            isHiddenWhiteContainer = false
        }
    }
    
    func showBackgroundContentWithAnimation(isVisible: Bool) {
        
        if isVisible {
            if !isHiddenWhiteContainer {
                return
            }
            isHiddenWhiteContainer = false
            viewShadow.backgroundColor = .white
            viewShadow.addTableCellShadowStyle()
            UIView.animate(withDuration: Constants.animationDuration) {
                self.viewShadow.alpha = 1
            }
        }
        else {
            if isHiddenWhiteContainer {
                return
            }
            isHiddenWhiteContainer = true
            UIView.animate(withDuration: Constants.animationDuration) {
                self.viewShadow.alpha = 0
            }
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
        
        isMovingAnimation = false
        
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
