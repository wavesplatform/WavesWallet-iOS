//
//  TooltipButtonCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

final class TooltipButtonCell: UITableViewCell, Reusable {
    
    @IBOutlet var button: UIButton!
    
    var didTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func handlerTap() {
        didTap?()
    }
}
