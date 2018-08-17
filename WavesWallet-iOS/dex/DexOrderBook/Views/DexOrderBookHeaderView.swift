//
//  DexOrderBookHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let cornerRadius: CGFloat = 3
}

final class DexOrderBookHeaderView: UIView, NibOwnerLoadable {
    
    
    @IBOutlet private weak var labelAmountAssetName: UILabel!
    @IBOutlet private weak var labelPriceAssetName: UILabel!
    @IBOutlet private weak var labelSumAssetName: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupCorners()
    }
    
    func setWhiteState() {
        backgroundColor = .white
        subviews.forEach{ $0.isHidden = true }
    }
    
    func setDefaultState() {
        backgroundColor = .basic50
        subviews.forEach{ $0.isHidden = false }
    }
}

//MARK: - SetupUI
private extension DexOrderBookHeaderView {
    
    func setupTitles() {
        labelAmountAssetName.text = Localizable.DexOrderBook.Label.amount + " " + "Waves"
        labelPriceAssetName.text = Localizable.DexOrderBook.Label.price + " " + "BTC"
        labelSumAssetName.text = Localizable.DexOrderBook.Label.sum + " " + "BTC"
    }
    
    func setupCorners() {
        let shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: Constants.cornerRadius, height: Constants.cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = shadowPath.cgPath
        layer.mask = maskLayer
    }
}
