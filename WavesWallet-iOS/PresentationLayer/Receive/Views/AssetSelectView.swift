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
    
    private var taskForAssetLogo: RetrieveImageDiskTask?

    weak var delegate: AssetSelectViewDelegate?
    var isSelectedAssetMode: Bool = true {
        didSet {
            updateViewStyle()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelAssetLocalization.text = Localizable.Waves.Receive.Label.asset
        labelSelectAsset.text = Localizable.Waves.Receive.Label.selectYourAsset
        viewAsset.isHidden = true
        updateViewStyle()
    }
    
    @IBAction private func buttonTapped(_ sender: Any) {
        if !isSelectedAssetMode {
            return
        }
        delegate?.assetViewDidTapChangeAsset()
    }
    
    func setupAssetWavesMode() {
        viewAsset.isHidden = false
        labelSelectAsset.isHidden = true
        

//        labelAssetName.text = wavesTitle
//        labelAmount.isHidden = true
//        iconGateway.isHidden = true
//
//        loadIcon(name: Environments.Constants.wavesAssetId)
    }
    
    func showAmount() {
        labelAmount.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
}

//MARK: - ViewConfiguration
extension AssetSelectView: ViewConfiguration {
    
    func update(with model: DomainLayer.DTO.AssetBalance) {
        
        guard let asset = model.asset else { return }
        
        viewAsset.isHidden = false
        labelAmount.isHidden = false
        labelSelectAsset.isHidden = true

        labelAssetName.text = asset.displayName
        iconGateway.isHidden = !asset.isGateway
        iconFav.isHidden = !(model.settings?.isFavorite ?? false)
       
        loadIcon(name: asset.ticker ?? asset.displayName)
        let money = Money(model.balance, asset.precision)
        labelAmount.text = money.displayTextFull
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
    
    func updateViewStyle() {
        
        iconArrows.isHidden = !isSelectedAssetMode
        
        if isSelectedAssetMode {
            assetRightOffset.constant = Constants.assetRightOffsetSelectedMode

            viewContainer.backgroundColor = .white
            viewContainer.layer.cornerRadius = 0
            viewContainer.layer.borderWidth = 0
            viewContainer.layer.borderColor = nil
            
            viewContainer.addTableCellShadowStyle()
            
        }
        else {
            assetRightOffset.constant = Constants.assetRightOffsetNotSelectedMode

            viewContainer.layer.removeShadow()
            
            viewContainer.backgroundColor = .clear
            viewContainer.layer.cornerRadius = Constants.borderRadius
            viewContainer.layer.borderWidth = Constants.borderWidth
            viewContainer.layer.borderColor = UIColor.overlayDark.cgColor
        }
    }
}
