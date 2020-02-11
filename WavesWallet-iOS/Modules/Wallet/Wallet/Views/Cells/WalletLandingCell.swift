//
//  WalletLandingCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

private enum Constants {
    static let blueViewRadius = CGSize(width: 14, height: 14)
}

final class WalletLandingCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var blueTopView: UIView!
    @IBOutlet private weak var labelEarnPercent: UILabel!
    @IBOutlet private weak var labelAnnualInterests: UILabel!
    @IBOutlet private weak var labelMoney: UILabel!
    @IBOutlet private weak var labelProfitStaking: UILabel!
    @IBOutlet private weak var buttonNext: HighlightedButton!
    @IBOutlet private weak var labelHowItWorks: UILabel!
    
    private let shapeLayer = CAShapeLayer()
    private var currentPageIndex: Int = 0
    
    var startStaking:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        blueTopView.layer.mask = shapeLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let maskPath = UIBezierPath(roundedRect: blueTopView.bounds,
                                    byRoundingCorners: [.topLeft, .bottomLeft],
                                    cornerRadii: Constants.blueViewRadius)

        shapeLayer.path = maskPath.cgPath
    }
    
    @IBAction private func nextTapped(_ sender: Any) {
    
        startStaking?()
        setupNextButtonTitle()
    }
    
    private func setupNextButtonTitle() {
        
        //TODO -  поравить логику
        if currentPageIndex == 0 {
            buttonNext.setTitle(Localizable.Waves.Wallet.Landing.next, for: .normal)
        }
        else {
            buttonNext.setTitle(Localizable.Waves.Wallet.Landing.startStaking, for: .normal)
        }
    }
}

extension WalletLandingCell: ViewConfiguration {
    
//    struct Model {
//        let totalValue: Money
//        let percent: Double
//        let minimumDeposite: Money
//    }
    
    func update(with model: WalletTypes.DTO.Staking.Landing) {
        
        let percent = String(format: "%.02f", model.percent)
        let earnPercent = Localizable.Waves.Wallet.Landing.earn(percent + "%")
        var attr = NSMutableAttributedString(string: earnPercent)
        attr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.submit300],
                           range: (attr.string as NSString).range(of: percent))
        labelEarnPercent.attributedText = attr
        
        
        let totalValue = Money(314314,2)
        
        attr = NSMutableAttributedString(string: "$" + totalValue.displayText)
        attr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.submit300],
                           range: (attr.string as NSString).range(of: totalValue.displayText))
        labelMoney.attributedText = attr
                
        let minimunStaking = "$" + model.minimumDeposit.displayText + "."
        attr = NSMutableAttributedString(string: Localizable.Waves.Wallet.Landing.profitWhenStaking(minimunStaking))
        attr.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: labelProfitStaking.font.pointSize)],
                           range: (attr.string as NSString).range(of: minimunStaking))
        labelProfitStaking.attributedText = attr
        
        labelHowItWorks.text = Localizable.Waves.Wallet.Landing.howItWorks
        labelAnnualInterests.text = Localizable.Waves.Wallet.Landing.annualInterest
    
        setupNextButtonTitle()
    }
}

private extension WalletLandingCell {
    func setupUI() {
        
    }
}
