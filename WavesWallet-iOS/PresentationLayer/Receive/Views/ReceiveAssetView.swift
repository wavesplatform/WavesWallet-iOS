//
//  ReceiveAssetView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/3/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol ReceiveAssetViewDelegate: AnyObject {
    
    func receiveAssetViewDidTapChangeAsset()
}

final class ReceiveAssetView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var labelAssetLocalization: UILabel!
    @IBOutlet private weak var labelSelectAsset: UILabel!
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var viewAsset: UIView!
    @IBOutlet private weak var iconAssetLogo: UIImageView!
    @IBOutlet private weak var iconGateway: UIImageView!
    @IBOutlet private weak var labelAssetName: UILabel!
    @IBOutlet private weak var iconFav: UIImageView!
    @IBOutlet private weak var labelAmount: UILabel!
    
    weak var delegate: ReceiveAssetViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelAssetLocalization.text = Localizable.Receive.Label.asset
        labelSelectAsset.text = Localizable.Receive.Label.selectYourAsset
        viewContainer.addTableCellShadowStyle()
    }
    
    @IBAction private func buttonTapped(_ sender: Any) {
        delegate?.receiveAssetViewDidTapChangeAsset()
    }
}

//MARK: - ViewConfiguration
extension ReceiveAssetView: ViewConfiguration {
    
    func update(with model: Void) {
        viewAsset.isHidden = false
        labelSelectAsset.isHidden = true
    }
}
