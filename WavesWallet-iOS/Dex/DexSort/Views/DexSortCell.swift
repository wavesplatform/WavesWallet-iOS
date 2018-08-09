//
//  DexSortingCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexSortCell: UITableViewCell, Reusable {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    
    var buttonDeleteDidTap: (() -> Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewContainer.addTableCellShadowStyle()
    }

    @IBAction func deleteTapped(_ sender: Any) {
        buttonDeleteDidTap?()
    }
}

extension DexSortCell: ViewConfiguration {
    func update(with model: DexSort.DTO.DexSortModel) {
        labelTitle.text = model.name
    }
}
