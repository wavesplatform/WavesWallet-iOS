//
//  AssetsSearchEmptyCell.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 06.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import DomainLayer
import Extensions
import RxSwift

final class AssetsSearchEmptyCell: UITableViewCell, Reusable {
    
    @IBOutlet private var titleLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = Localizable.Waves.Assetsearch.Cell.Empty.title
    }
}
