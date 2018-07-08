//
//  WalletTopTableCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol WalletTopTableCellDelegate: class {
    
    func walletTopTableCellDidChangeIndex(_ index: WalletViewController.WalletSelectedIndex)
}

class WalletTopTableCell: UITableViewCell {
    
    @IBOutlet weak var buttonAssets: UIButton!
    @IBOutlet weak var buttonLeasing: UIButton!
    @IBOutlet weak var leftBgViewOffset: NSLayoutConstraint!
    
    var delegate: WalletTopTableCellDelegate?
    
    var selectedIndex = WalletViewController.WalletSelectedIndex.assets
    
    class func cellHeight() -> CGFloat {
        return 60
    }
    
    func setupState(_ state: WalletViewController.WalletSelectedIndex, animation: Bool) {
        
        selectedIndex = state
        
        if state == .assets {
            leftBgViewOffset.constant = 16
            buttonAssets.setTitleColor(UIColor.white, for: .normal)
            buttonLeasing.setTitleColor(UIColor.basic500, for: .normal)
        }
        else {
            leftBgViewOffset.constant = 126
            buttonAssets.setTitleColor(UIColor.basic500, for: .normal)
            buttonLeasing.setTitleColor(UIColor.white, for: .normal)
        }
        
        if animation {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func assetsTapped(_ sender: Any) {
        if selectedIndex == .assets {
            return
        }
        setupState(.assets, animation: true)
        delegate?.walletTopTableCellDidChangeIndex(selectedIndex)
    }
    
    @IBAction func leasingTapped(_ sender: Any) {
        
        if selectedIndex == .leasing {
            return
        }
        setupState(.leasing, animation: true)
        delegate?.walletTopTableCellDidChangeIndex(selectedIndex)
    }
}
