//
//  SendFeeHeaderCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/31/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 40
}

final class SendFeeHeaderCell: UITableViewCell, Reusable {
    
    @IBOutlet private weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelTitle.text = Localizable.Waves.Sendfee.Label.transactionFee
    }
}

extension SendFeeHeaderCell: ViewHeight {
    
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
