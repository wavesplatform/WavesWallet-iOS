//
//  WidgetSettingsHeader.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 29.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

private struct Constants {}

final class WidgetSettingsHeaderView: UITableViewHeaderFooterView, NibReusable {
    
    struct Model {
        let amountMax: Int
        let amount: Int
    }
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView = {
           
            let view = UIView()
            view.backgroundColor = .basic50
            return view
        }()
    }
}

extension WidgetSettingsHeaderView: ViewConfiguration {
    
    func update(with model: WidgetSettingsHeaderView.Model) {
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: "\(model.amount)", attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .semibold)]))
        attributedString.append(NSAttributedString(string: " / \(model.amountMax)", attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular)]))
        labelAmount.attributedText = attributedString
    }
}
