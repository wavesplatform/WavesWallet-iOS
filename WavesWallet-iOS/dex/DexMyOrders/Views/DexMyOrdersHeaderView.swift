//
//  DexMyOrdersHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexMyOrdersHeaderView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet private weak var labelDate: UILabel!

    private static let dateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DexMyOrdersHeaderView.dateFormatter.dateFormat = "dd.MM.yyyy"
    }
}

extension DexMyOrdersHeaderView: ViewConfiguration {
    func update(with model: DexMyOrders.ViewModel.Header) {
        labelDate.text = DexMyOrdersHeaderView.dateFormatter.string(from: model.date)
    }
}
