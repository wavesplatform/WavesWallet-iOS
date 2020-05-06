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
import UITools

final class PayoutsTransactionCollectionViewCell: UICollectionViewContainerCell<PayoutsTransactionView>, ViewConfiguration {
    private var disposeBag = DisposeBag()

    // MARK: - Override

    override func initialSetup() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        clipsToBounds = false
        layer.masksToBounds = true
        layer.cornerRadius = 4
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        view.resetToEmptyState()
        disposeBag = DisposeBag()
    }

    // MARK: - ViewConfiguration

    func update(with model: PayoutTransactionVM) {
        if let icon = model.iconAsset {
            AssetLogo
                .logo(icon: icon, style: .large)
                .subscribe(onNext: { [weak self] in self?.view.setAssetImage($0) })
                .disposed(by: disposeBag)
        }

        view.setTitle(model.title,
                      transactionValue: model.transactionValue,
                      date: model.dateText)
    }
}

final class PayoutsTransactionCell: UITableViewCell, Reusable, NibLoadable, ResetableView, ViewConfiguration {
    @IBOutlet private weak var payoutsTransactionView: PayoutsTransactionView!

    private var disposeBag = DisposeBag()

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

    func update(with model: PayoutTransactionVM) {
        if let icon = model.iconAsset {
            AssetLogo
                .logo(icon: icon, style: .large)
                .subscribe(onNext: { [weak self] in self?.payoutsTransactionView.setAssetImage($0) })
                .disposed(by: disposeBag)
        }

        payoutsTransactionView.setTitle(model.title,
                                        transactionValue: model.transactionValue,
                                        date: model.dateText)
    }

    private func initialSetup() {
        backgroundColor = .basic50
        contentView.backgroundColor = .basic50

        selectionStyle = .none

        clipsToBounds = false
        layer.masksToBounds = true
    }

    func resetToEmptyState() {
        payoutsTransactionView.resetToEmptyState()

        disposeBag = DisposeBag()
    }
}

/// ViewModel предназначенная для использования вместе с PayoutsTransactionView
struct PayoutTransactionVM {
    /// Заголовок транзакции
    let title: String

    /// Иконка транзакции
    let iconAsset: AssetLogo.Icon?

    /// Значение транзакции (в данном случае всегда положительное)
    let transactionValue: BalanceLabel.Model

    /// Дата транзакции
    let dateText: String

    init(title: String, iconAsset: AssetLogo.Icon?, transactionValue: BalanceLabel.Model, dateText: String) {
        self.title = title
        self.iconAsset = iconAsset
        self.transactionValue = transactionValue
        self.dateText = dateText
    }
}

final class PayoutsTransactionView: UIView, NibOwnerLoadable, ResetableView {
    @IBOutlet private weak var assetImageView: UIImageView!
    @IBOutlet private weak var titleTransactionLabel: UILabel!
    @IBOutlet private weak var transactionCurrencyContainerView: BalanceLabel!
    @IBOutlet private weak var dateTransactionLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()

        resetToEmptyState()
        initialSetup()
    }

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
        setupDefaultShadows()

        do {
            assetImageView.contentMode = .scaleAspectFit
        }

        do {
            titleTransactionLabel.numberOfLines = 0
            titleTransactionLabel.font = .systemFont(ofSize: 13)
            titleTransactionLabel.textColor = .basic500

            dateTransactionLabel.textAlignment = .right
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
