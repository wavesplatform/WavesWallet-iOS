//
//  DexSortingCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexSortingCell: UITableViewCell, Reusable {

    
    @IBOutlet weak var viewContainer: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }

}
