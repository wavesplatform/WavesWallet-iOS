//
//  ReceiveAssetView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/3/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import Kingfisher

private enum Constants {
    static let borderRadius: CGFloat = 2
    static let borderWidth: CGFloat = 0.5
    static let assetRightOffsetSelectedMode: CGFloat = 36
    static let assetRightOffsetNotSelectedMode: CGFloat = 14
    static let icon = CGSize(width: 24, height: 24)
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
    @IBOutlet private weak var iconGateway: UIImageView!
    @IBOutlet private weak var labelAssetName: UILabel!
    @IBOutlet private weak var iconFav: UIImageView!
    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var iconArrows: UIImageView!
    @IBOutlet private weak var assetRightOffset: NSLayoutConstraint!
    @IBOutlet private weak var buttonTap: UIButton!
    @IBOutlet private weak var skeletonView: AssetSelectSkeletonView!
    
    private var taskForAssetLogo: RetrieveImageDiskTask?

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
        iconGateway.isHidden = true
        
        loadIcon(name: GlobalConstants.wavesAssetId)
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
        iconGateway.isHidden = !asset.isGateway
        iconFav.isHidden = !model.assetBalance.settings.isFavorite
       
        loadIcon(name: asset.icon)
        let money = Money(model.assetBalance.avaliableBalance, asset.precision)
        labelAmount.text = money.displayText
    }
    
    private func loadIcon(name: String) {

        taskForAssetLogo?.cancel()
        let style = AssetLogo.Style(size: Constants.icon, font: UIFont.systemFont(ofSize: 15), border: nil)
        taskForAssetLogo = AssetLogo.logoFromCache(name: name, style: style, completionHandler: { [weak self] (image) in
            self?.iconAssetLogo.image = image
        })
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
