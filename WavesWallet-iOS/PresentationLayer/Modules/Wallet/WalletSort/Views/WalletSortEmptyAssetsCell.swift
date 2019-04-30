//
//  WalletSortEmptyCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/23/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let defaultHeight: CGFloat = 130
    static let assetListHeight: CGFloat = 180
}

final class WalletSortEmptyAssetsCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var imageIcon: UIImageView!
    @IBOutlet private weak var labelTitle: UILabel!
    
}

extension WalletSortEmptyAssetsCell: ViewConfiguration {
    
    func update(with model: WalletSort.ViewModel.AssetType) {
        
        switch model {
        case .favourite:
            imageIcon.image = Images.favorite14Submit300.image
            labelTitle.text = Localizable.Waves.Walletsort.Label.notAddedAssetsInFavorites
            
        case .list:
            imageIcon.image = Images.userimgEmpty80Multi.image
            labelTitle.text = Localizable.Waves.Walletsort.Label.listOfAssetsEmpty
            
        case .hidden:
            imageIcon.image = Images.visibility18Basic500.image
            labelTitle.text = Localizable.Waves.Walletsort.Label.notAddedAssetsInHidden
        }
        
    }
}

extension WalletSortEmptyAssetsCell: ViewCalculateHeight {
    
    static func viewHeight(model: WalletSort.ViewModel.AssetType, width: CGFloat) -> CGFloat {
        
        switch model {
        case .list:
            return Constants.assetListHeight
        default:
            return Constants.defaultHeight
        }
    }
}

