//
//  BaseTransactionDetailViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 27/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import RealmSwift
import UILabel_Copyable

class BaseTransactionDetailViewController: UITableViewController, HalfModalPresentable {
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var assetNameLabel: UILabel!
    @IBOutlet weak var assetIdLabel: UILabel!
    @IBOutlet weak var txIdLabel: UILabel!
    
    var tx: Transaction!
    var basicTx: BasicTransaction!
    
    var issue: IssueTransaction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFields()
    }
    
    @IBAction func onMaximize(_ sender: Any) {
        maximizeToFullScreen()
    }
    
    @IBAction func onClose(_ sender: Any) {
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func setupFields() {
        switch tx.type {
        case 2 :
            transactionTypeLabel.text = "Payment"
        case 3 :
            transactionTypeLabel.text = "Issue"
        case 4 :
            transactionTypeLabel.text = "Transfer"
        case 5 :
            transactionTypeLabel.text = "Reissue"
        case 6 :
            transactionTypeLabel.text = "Burn"
        case 7 :
            transactionTypeLabel.text = "Exchange"
        case 8 :
            transactionTypeLabel.text = "Lease"
        case 9 :
            transactionTypeLabel.text = "Cancel Lease"
        default:
            transactionTypeLabel.text = "Transaction"
        }
        
        directionLabel.text = basicTx.isInput ? "Received" : "Sent"
        directionLabel.textColor = basicTx.isInput ? AppColors.receiveGreen : AppColors.sendRed
        amountLabel.text = MoneyUtil.getScaledText(tx.getAmount(), decimals: Int(basicTx.asset?.decimals ?? 0))
        feeLabel.text = "Transaction fee: \(MoneyUtil.getScaledTextTrimZeros(tx.fee, decimals: 8)) WAVES"
        dateLabel.text = DateUtil.formatFull(ts: tx.timestamp)
        fromLabel.text = tx.sender
        fromLabel.copyingEnabled = true
        assetIdLabel.text = basicTx.assetId
        assetNameLabel.text = basicTx.asset?.name ?? "WAVES"
        txIdLabel.text = basicTx.id

        txIdLabel.copyingEnabled = true
        assetIdLabel.copyingEnabled = true
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

}
