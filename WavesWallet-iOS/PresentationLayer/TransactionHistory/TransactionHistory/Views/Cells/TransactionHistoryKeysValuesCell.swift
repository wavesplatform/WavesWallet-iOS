//
//  TransactionHistoryKeysValue.swift
//  WavesWallet-iOS
//
//  Created by Mac on 31/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionHistoryKeysValuesCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var firstTitleLabel: UILabel!
    @IBOutlet weak var firstValueLabel: UILabel!
    @IBOutlet weak var secondTitleLabel: UILabel!
    @IBOutlet weak var secondValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

    }
    
    class func cellHeight() -> CGFloat {
        return 66
    }
}

extension TransactionHistoryKeysValuesCell: ViewConfiguration {
    func update(with model: [TransactionHistoryTypes.ViewModel.KeyValue]) {
        
        let firstModel = model[0]
        firstTitleLabel.text = firstModel.title
        firstValueLabel.text = firstModel.value
        
        let secondModel = model[1]
        secondTitleLabel.text = secondModel.title
        secondValueLabel.text = secondModel.value
        
    }
}
