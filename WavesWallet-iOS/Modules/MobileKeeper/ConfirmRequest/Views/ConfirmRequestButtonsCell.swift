//
//  ConfirmRequestButtonsCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 29.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import Extensions

final class ConfirmRequestButtonsCell: UITableViewCell, Reusable {
    
    @IBOutlet private var rejectButton: UIButton!
    @IBOutlet private var approveButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectedBackgroundView = UIView()
        selectionStyle = .none
    }
    
    @IBAction func rejectHadlerTouch() {
        
    }
    
    @IBAction func approveHadlerTouch() {
        
    }
}
