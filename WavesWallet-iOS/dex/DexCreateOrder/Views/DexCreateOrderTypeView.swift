//
//  DexSellBuyTypeOrderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/11/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol DexCreateOrderTypeViewDelegate: AnyObject {
    
    func dexCreateOrderDidChangeType(_ type: DexCreateOrder.DTO.OrderType)
}

final class DexCreateOrderTypeView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var buttonBuy: UIButton!
    @IBOutlet private weak var buttonSell: UIButton!
    @IBOutlet private weak var viewPosition: UIView!
    @IBOutlet private weak var viewPositionOffset: NSLayoutConstraint!
    
    weak var delegate: DexCreateOrderTypeViewDelegate?
    
    var type: DexCreateOrder.DTO.OrderType! {
        didSet {
            if type == .sell {
                buttonSell.setTitleColor(.black, for: .normal)
                buttonBuy.setTitleColor(.basic500, for: .normal)
                viewPosition.backgroundColor = .error400
            }
            else {
                buttonSell.setTitleColor(.basic500, for: .normal)
                buttonBuy.setTitleColor(.black, for: .normal)
                viewPosition.backgroundColor = .submit400
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonBuy.setTitle(Localizable.DexCreateOrder.Button.buy, for: .normal)
        buttonSell.setTitle(Localizable.DexCreateOrder.Button.sell, for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupViewPositionOffset(animation: false)
    }
}

//MARK: - Setup
private extension DexCreateOrderTypeView {
    
    func setupViewPositionOffset(animation: Bool) {
        let buttonWidth = frame.size.width / 2
        let buttonPosition: CGFloat = type == .sell ? buttonWidth : 0

        viewPositionOffset.constant = buttonPosition + (buttonWidth - viewPosition.frame.size.width) / 2

        if animation {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
}

//MARK: - Actions
private extension DexCreateOrderTypeView {
    
    
    @IBAction func buyTapped(_ sender: UIButton) {
        guard type != .buy else { return }
        type = .buy
        setupViewPositionOffset(animation: true)
        delegate?.dexCreateOrderDidChangeType(type)
    }
    
    @IBAction func sellTapped(_ sender: UIButton) {
        guard type != .sell else { return }
        type = .sell
        setupViewPositionOffset(animation: true)
        delegate?.dexCreateOrderDidChangeType(type)
    }
    
}
