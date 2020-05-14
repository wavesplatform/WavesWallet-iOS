//
//  AmountField.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 20.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit
import UITools

final class BalanceInputField: UIView, NibOwnerLoadable {
    enum Style: Hashable {
        case normal
        case error
    }

    enum State: Hashable {
        case empty(_ decimal: Int, _ currency: DomainLayer.DTO.Balance.Currency)
        case balance(DomainLayer.DTO.Balance)
    }

    struct Model: Hashable {
        let style: Style
        let state: State
    }

    @IBOutlet private weak var numberTextField: MoneyTextField!
    @IBOutlet private var tickerView: TickerView!
    @IBOutlet private var separatorView: SeparatorView!

    var style: Style = .normal {
        didSet {
            setNeedUpdateStyle()
        }
    }

    var didChangeInput: ((_ value: Money?) -> Void)?

    var didTapButtonDoneOnKeyboard: (() -> Void)?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        numberTextField.moneyDelegate = self
    }

    override func becomeFirstResponder() -> Bool {
        return numberTextField.becomeFirstResponder()
    }

    func setKeyboardType(_ type: UIKeyboardType) {
        numberTextField.keyboardType = type
    }
}

// MARK: - Private Methods

private extension BalanceInputField {
    func setNeedUpdateStyle() {
        switch style {
        case .normal:
            separatorView.lineColor = UIColor.accent100
        case .error:
            separatorView.lineColor = UIColor.error500
        }
    }
}

// MARK: - ViewConfiguration

extension BalanceInputField: ViewConfiguration {
    func update(with model: Model) {
        style = model.style

        switch model.state {
        case let .empty(decimal, currency):
            tickerView.update(with: .init(text: currency.displayText,
                                          style: .normal))
            numberTextField.setDecimals(decimal)
            numberTextField.clearInput()

        case let .balance(balance):

            tickerView.update(with: .init(text: balance.currency.displayText,
                                          style: .normal))
            numberTextField.value = balance.money
        }
    }
}

// TODO: MoneyTextFieldDelegate

extension BalanceInputField: MoneyTextFieldDelegate {
    func moneyTextField(_ textField: MoneyTextField, didChangeValue value: Money) {
        didChangeInput?(textField.hasInput == true ? value : nil)
    }

    func moneyTextFieldShouldReturn() -> Bool {
        didTapButtonDoneOnKeyboard?()
        return true
    }
}
