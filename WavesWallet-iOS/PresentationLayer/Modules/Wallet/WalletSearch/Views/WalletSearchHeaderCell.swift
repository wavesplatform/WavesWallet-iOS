//
//  WalletSearchHeaderCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/3/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 52
}

final class WalletSearchHeaderCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension WalletSearchHeaderCell: ViewConfiguration {

    func update(with model: WalletSearch.ViewModel.Kind) {
        switch model {
        case .hidden:
            labelTitle.text = Localizable.Waves.Walletsearch.Label.hiddenTokens
        
        case .spam:
            labelTitle.text = Localizable.Waves.Walletsearch.Label.suspiciousTokens
        default:
            break
        }
    }
}

extension WalletSearchHeaderCell: ViewHeight {
 
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
