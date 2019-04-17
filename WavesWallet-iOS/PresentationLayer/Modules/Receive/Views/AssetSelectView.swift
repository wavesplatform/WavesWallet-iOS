//
//  ReceiveAssetView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/3/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import WavesSDKExtension
import WavesSDKCrypto

private enum Constants {
    static let borderRadius: CGFloat = 2
    static let borderWidth: CGFloat = 0.5
    static let assetRightOffsetSelectedMode: CGFloat = 36
    static let assetRightOffsetNotSelectedMode: CGFloat = 14
    static let icon = CGSize(width: 24, height: 24)
    static let sponsoredIcon = CGSize(width: 10, height: 10)
}

protocol AssetSelectViewDelegate: AnyObject {
    
    func assetViewDidTapChangeAsset()
}

final class AssetSelectView: UIView, NibOwnerLoadable {
    
    
    @IBOutlet private weak var viewContainer: UIView!

    @IBOutlet private weak var labelAssetLocalization: UILabel!
    @IBOutlet private weak var labelSelectAsset: UILabel!
    @IBOutlet private weak var viewAsset: UIView!
    @IBOutlet private weak var iconAssetLogo: UIImageView!
    @IBOutlet private weak var labelAssetName: UILabel!
    @IBOutlet private weak var iconFav: UIImageView!
    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var iconArrows: UIImageView!
    @IBOutlet private weak var assetRightOffset: NSLayoutConstraint!
    @IBOutlet private weak var buttonTap: UIButton!
    @IBOutlet private weak var skeletonView: AssetSelectSkeletonView!
    
    private var disposeBag: DisposeBag = DisposeBag()

    weak var delegate: AssetSelectViewDelegate?
    var isSelectedAssetMode: Bool = true {
        didSet {
            updateViewStyle()
        }
    }
    private(set) var isOnlyBlockMode: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelAssetLocalization.text = Localizable.Waves.Receive.Label.asset
        labelSelectAsset.text = Localizable.Waves.Receive.Label.selectYourAsset
        viewAsset.isHidden = true
        updateViewStyle()
    }
    
    @IBAction private func buttonTapped(_ sender: Any) {
        delegate?.assetViewDidTapChangeAsset()
    }
  
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    func setupReveiceWavesLoadingState() {
        viewAsset.isHidden = false
        labelSelectAsset.isHidden = true
        
        labelAssetName.text = "Waves"
        labelAmount.isHidden = true

        //TODO: mb get url from enviromnets
        loadIcon(icon: .init(name: WavesSDKCryptoConstants.wavesAssetId,
                             url: nil), isSponsored: false, hasScript: false)
    }
    
    func showLoadingState() {
        viewAsset.isHidden = true
        labelSelectAsset.isHidden = true
        skeletonView.startAnimation(showArrows: !self.isOnlyBlockMode)
        addBorderShadow()
    }
    
    func hideLoadingState(isLoadAsset: Bool) {

        skeletonView.hide()
        
        if isLoadAsset {
            viewAsset.isHidden = false
        }
        else {
            isSelectedAssetMode = true
            labelSelectAsset.isHidden = false
        }
        updateViewStyle()
    }
    
    func removeSelectedAssetState() {
        viewAsset.isHidden = true
        labelSelectAsset.isHidden = false
        skeletonView.hide()
    }
}

//MARK: - ViewConfiguration
extension AssetSelectView: ViewConfiguration {
    
    struct Model {
        let assetBalance: DomainLayer.DTO.SmartAssetBalance
        let isOnlyBlockMode: Bool
    }
    
    func update(with model: Model) {
        
        isOnlyBlockMode = model.isOnlyBlockMode
        let asset = model.assetBalance.asset
        
        viewAsset.isHidden = false
        labelAmount.isHidden = false
        labelSelectAsset.isHidden = true

        labelAssetName.text = asset.displayName
        iconFav.isHidden = !model.assetBalance.settings.isFavorite

        loadIcon(icon: asset.iconLogo, isSponsored: model.assetBalance.asset.isSponsored, hasScript: model.assetBalance.asset.hasScript)
        let money = Money(model.assetBalance.availableBalance, asset.precision)
        labelAmount.text = money.displayText
    }
    
    private func loadIcon(icon: DomainLayer.DTO.Asset.Icon, isSponsored: Bool, hasScript: Bool) {

        disposeBag = DisposeBag()

        AssetLogo.logo(icon: icon,
                       style: AssetLogo.Style(size: Constants.icon,
                                              font: UIFont.systemFont(ofSize: 15),
                                              specs: .init(isSponsored: isSponsored,
                                                           hasScript: hasScript,
                                                           size: Constants.sponsoredIcon)))
            .observeOn(MainScheduler.instance)
            .bind(to: iconAssetLogo.rx.image)
            .disposed(by: disposeBag)
    }
}

//MARK: - Setup UI
private extension AssetSelectView {
    
    func addBorderShadow() {
        viewContainer.backgroundColor = .white
        viewContainer.layer.cornerRadius = 0
        viewContainer.layer.borderWidth = 0
        viewContainer.layer.borderColor = nil
        viewContainer.addTableCellShadowStyle()
    }
    
    func removeBorderShadow() {
        viewContainer.layer.removeShadow()
        viewContainer.backgroundColor = .clear
        viewContainer.layer.cornerRadius = Constants.borderRadius
        viewContainer.layer.borderWidth = Constants.borderWidth
        viewContainer.layer.borderColor = UIColor.overlayDark.cgColor
    }
    
    func updateViewStyle() {
        
        iconArrows.isHidden = !isSelectedAssetMode
        
        if isSelectedAssetMode {
            buttonTap.isUserInteractionEnabled = true
            assetRightOffset.constant = Constants.assetRightOffsetSelectedMode
            addBorderShadow()
        }
        else {
            buttonTap.isUserInteractionEnabled = false
            assetRightOffset.constant = Constants.assetRightOffsetNotSelectedMode
            removeBorderShadow()
        }
    }
}
