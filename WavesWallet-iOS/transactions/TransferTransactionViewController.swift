//
//  TransferTransactionViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 25/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class TransferTransactionViewController: BaseTransactionDetailViewController {
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var attachmentLabel: UILabel!

    override func setupFields() {
        super.setupFields()
        if let ttx = tx as? TransferTransaction {
            toLabel.text = ttx.recipient
            attachmentLabel.text = String(data: Data(Base58.decode(ttx.attachment ?? "")), encoding: .utf8)
        }
        

    }
}
