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
    
    static func cellHeight() -> CGFloat {
        170
    }
}

final class ExchangeTitleView: UIView, NibLoadable, ResetableView {
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlerTapWavesLogo))
    private var didTapDebug: VoidClosure?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    func resetToEmptyState() {
        titleLabel.text = nil
        didTapDebug = nil
    }
    
    private func initialSetup() {
        tapGesture.numberOfTapsRequired = 5
        
        titleLabel.textColor = .basic500
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        logoImageView.isUserInteractionEnabled = true
        logoImageView.addGestureRecognizer(tapGesture)
        logoImageView.image = Images.exchangeBlack.image
    }
    
    @objc private func handlerTapWavesLogo() {
        didTapDebug?()
    }
    
    func setTitleText(_ text: String, didTapDebug: @escaping VoidClosure) {
        titleLabel.text = text
        self.didTapDebug = didTapDebug
    }
}
