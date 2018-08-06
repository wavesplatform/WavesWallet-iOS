//
//  AssetLastTransactionView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class AssetLastTransactionView: UIView {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelAssetName: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }
}
