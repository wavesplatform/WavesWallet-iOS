//
//  ExchangeTitleCell.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 31.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Extensions
import UIKit

final class ExchangeTitleCell: UITableViewXibContainerCell<ExchangeTitleView> {
    override func initialSetup() {
        selectionStyle = .none
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        view.resetToEmptyState()
    }
}

final class ExchangeTitleView: UIView, NibLoadable, ResetableView {
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    func resetToEmptyState() {
        titleLabel.text = nil
    }
    
    private func initialSetup() {
        titleLabel.textColor = .basic500
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        logoImageView.image = Images.exchangeBlack.image
    }
    
    func setTitleText(_ text: String) {
        titleLabel.text = text
    }
}
