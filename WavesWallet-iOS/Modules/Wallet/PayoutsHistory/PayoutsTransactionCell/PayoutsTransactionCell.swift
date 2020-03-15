//
//  PaymentTransactionCell.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 04.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Extensions
import RxSwift
import UIKit

final class PayoutsTransactionCell: UITableViewCell, Reusable, NibLoadable, ResetableView {
    @IBOutlet private weak var payoutsTransactionView: PayoutsTransactionView!
    
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetToEmptyState()
    }
    
    func configure(_ viewModel: PayoutsHistoryState.UI.PayoutTransactionVM) {
        if let icon = viewModel.iconAsset {
            AssetLogo
                .logo(icon: icon, style: .tiny)
                .subscribe(onNext: { [weak self] in self?.payoutsTransactionView.setAssetImage($0) })
                .disposed(by: disposeBag)
        }
        
        payoutsTransactionView.setTitle(viewModel.title,
                                        transactionValue: viewModel.transactionValue,
                                        date: viewModel.dateText)
    }
    
    private func initialSetup() {
        selectionStyle = .none
        
        clipsToBounds = false
        layer.masksToBounds = true
    }
    
    func resetToEmptyState() {
        payoutsTransactionView.resetToEmptyState()
    }
}

final class PayoutsTransactionView: UIView, NibOwnerLoadable, ResetableView {
    @IBOutlet private weak var assetImageView: UIImageView!
    @IBOutlet private weak var titleTransactionLabel: UILabel!
    @IBOutlet private weak var transactionCurrencyContainerView: BalanceLabel!
    @IBOutlet private weak var dateTransactionLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        resetToEmptyState()
        initialSetup()
    }
    
    private func initialSetup() {
        do {
            let shadowColor = UIColor.black.withAlphaComponent(0.08)
            let shadowOptions = ShadowOptions(offset: CGSize(width: 0, height: 0),
                                              color: shadowColor,
                                              opacity: 1,
                                              shadowRadius: 4,
                                              shouldRasterize: true)
            setupShadow(options: shadowOptions)
        }
        
        do {
            assetImageView.contentMode = .scaleAspectFit
        }
        
        do {
            titleTransactionLabel.numberOfLines = 0
            titleTransactionLabel.font = .systemFont(ofSize: 13)
            titleTransactionLabel.textColor = .basic500
            
            dateTransactionLabel.numberOfLines = 0
            dateTransactionLabel.font = .systemFont(ofSize: 11)
            dateTransactionLabel.textColor = .basic500
        }
    }
    
    public func setTitle(_ text: String, transactionValue: BalanceLabel.Model, date: String) {
        titleTransactionLabel.text = text
        dateTransactionLabel.text = date
        transactionCurrencyContainerView.update(with: transactionValue)
    }
    
    public func setAssetImage(_ image: UIImage) {
        assetImageView.image = image
    }
    
    func resetToEmptyState() {
        assetImageView.image = nil
        titleTransactionLabel.text = nil
        dateTransactionLabel.text = nil
    }
}
