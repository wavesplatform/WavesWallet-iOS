//
//  ReceiveAssetView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/3/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class ReceiveAssetView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var labelAssetLocalization: UILabel!
    @IBOutlet private weak var labelSelectAsset: UILabel!
    @IBOutlet private weak var viewContainer: UIView!
    
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
}
