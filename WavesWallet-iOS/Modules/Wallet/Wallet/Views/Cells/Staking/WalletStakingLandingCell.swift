//
//  WalletLandingCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import TTTAttributedLabel

private enum Constants {
    static let blueViewRadius = CGSize(width: 14, height: 14)
    static let blueDottedViewRadius = CGSize(width: 10, height: 10)
    static let secondYear: Double = 31536000
}

final class WalletStakingLadingInfoView: UIView {
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var subTitleLabel: UILabel!
    @IBOutlet private(set) weak var imageView: UIImageView!
    
    @IBOutlet private weak var titleLabelTop: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
    }
}

final class WalletStakingLandingCell: MinHeightTableViewCell, NibReusable, Localization {

    @IBOutlet private weak var blueTopView: UIView!
    @IBOutlet private weak var labelEarnPercent: UILabel!
    @IBOutlet private weak var labelAnnualInterests: UILabel!
    @IBOutlet private weak var labelMoney: UILabel!
    @IBOutlet private weak var labelProfitStaking: UILabel!
    @IBOutlet private weak var buttonNext: HighlightedButton!
    @IBOutlet private weak var labelHowItWorks: UILabel!
    @IBOutlet private weak var faqLabel: TTTAttributedLabel!
    
    @IBOutlet private weak var firstInfoView: WalletStakingLadingInfoView!
    @IBOutlet private weak var secondInfoView: WalletStakingLadingInfoView!
    @IBOutlet private weak var thirdInfoView: WalletStakingLadingInfoView!
    @IBOutlet private weak var pageControl: PageControl!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private let shapeLayer = CAShapeLayer()
        
    private var model: Model? = nil
    
    private static var totalProfitValue: Double? = nil
    private var profitValue: Double? = nil
    
    public var startStaking: (() -> Void)?
    
    public var didSelectLinkWith: ((URL) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        blueTopView.layer.mask = shapeLayer
        
        _ = Timer.scheduledTimer(timeInterval: 0.1,
                                 target: self,
                                 selector: #selector(update(timer:)),
                                 userInfo: nil,
                                 repeats: true)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let maskPath = UIBezierPath(roundedRect: blueTopView.bounds,
                                    byRoundingCorners: [.topLeft, .bottomLeft],
                                    cornerRadii: Constants.blueDottedViewRadius)

        shapeLayer.path = maskPath.cgPath
    }
    
    @objc func update(timer: Timer) {
        
        guard let model = self.model else { return }
        guard let profitValue = profitValue else { return }
                        
        let totalProfitValue = WalletStakingLandingCell.totalProfitValue
        let money: Double = profitValue + (totalProfitValue ?? 0)
        
        WalletStakingLandingCell.totalProfitValue = money
        
        let amount = Int64(money * pow(10, Double(model.minimumDeposit.decimals)))
        let totalValue = Money(amount,
                               model.minimumDeposit.decimals)
                
        labelMoney.attributedText = NSMutableAttributedString.stakingProfit(totalValue: totalValue)
               
    }
    
    @IBAction private func nextTapped(_ sender: Any) {
        startStaking?()
    }
    
    private func ifNeedUpdateNextButton() {
                
        if scrollView.currentPage == 0 {
            buttonNext.setTitle(Localizable.Waves.Staking.Landing.next, for: .normal)
        } else {
            buttonNext.setTitle(Localizable.Waves.Staking.Landing.startStaking, for: .normal)
        }
    }
    
    func setupLocalization() {
        
        firstInfoView.titleLabel.text = Localizable.Waves.Staking.Landing.Slide.Buyusdn.title
        firstInfoView.subTitleLabel.text = Localizable.Waves.Staking.Landing.Slide.Buyusdn.subtitle
        
        secondInfoView.titleLabel.text = Localizable.Waves.Staking.Landing.Slide.Depositusdn.title
        secondInfoView.subTitleLabel.text = Localizable.Waves.Staking.Landing.Slide.Depositusdn.subtitle
        
        thirdInfoView.titleLabel.text = Localizable.Waves.Staking.Landing.Slide.Passiveincome.title
        thirdInfoView.subTitleLabel.text = Localizable.Waves.Staking.Landing.Slide.Passiveincome.subtitle
        
    }
}

extension WalletStakingLandingCell: ViewConfiguration {
        
    func update(with model: WalletTypes.DTO.Staking.Landing) {
        
        self.model = model
                
        self.profitValue = ((model.minimumDeposit.doubleValue * (model.percent / 100)) / Constants.secondYear) / 10
                        
        labelEarnPercent.attributedText = NSMutableAttributedString.stakingEarnPercent(percent: model.percent)
        labelAnnualInterests.text = Localizable.Waves.Staking.Landing.annualInterest
                                    
        labelProfitStaking.attributedText = NSMutableAttributedString.stakingProfitInfo(minimumDeposit: model.minimumDeposit)
        labelHowItWorks.text = Localizable.Waves.Staking.Landing.howItWorks
        
        let faq = NSMutableAttributedString.stakingFaq()
        faqLabel.attributedText = faq.string
        faqLabel.delegate = self
        
        if let url = URL(string: UIGlobalConstants.URL.stakingFaq) {
            
                                    
            faqLabel.activeLinkAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                                             NSAttributedString.Key.foregroundColor: UIColor.submit400,
                                             NSAttributedString.Key.underlineStyle: NSNumber(value: false)]
            faqLabel.linkAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                                       NSAttributedString.Key.foregroundColor: UIColor.submit400,
                                       NSAttributedString.Key.underlineStyle: NSNumber(value: false)]
            
            faqLabel.addLink(to: url, with: faq.faqRange)
        }
        
        setupLocalization()
        ifNeedUpdateNextButton()
    }
}

extension NSMutableAttributedString {
    
    static func stakingEarnPercent(percent: Double) -> NSMutableAttributedString {
                
        let percent = String(format: "%.02f", percent)
        let earnPercent = Localizable.Waves.Staking.Landing.earn(percent + "%")
        let attr = NSMutableAttributedString(string: earnPercent)
        
        attr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.submit300],
                           range: (attr.string as NSString).range(of: percent))
        
        return attr
    }
    
    static func stakingProfit(totalValue: Money) -> NSMutableAttributedString {
                                       
        let attr = NSMutableAttributedString(string: "$" + totalValue.displayText)
        attr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.submit300],
                           range: (attr.string as NSString).range(of: totalValue.displayTextFull(isFiat: false)))
        return attr
    }
            
    static func stakingProfitInfo(minimumDeposit: Money) -> NSMutableAttributedString {
                            
        let minimunStaking = "$" + minimumDeposit.displayText + "."
        
        let attr = NSMutableAttributedString(string: Localizable.Waves.Staking.Landing.profitWhenStaking(minimunStaking))
        attr.addAttributes([.font: UIFont.systemFont(ofSize: 13, weight: .light)], range: .init(location: 0, length: attr.string.count))
        attr.addAttributes([.font: UIFont.systemFont(ofSize: 13)],
                           range: (attr.string as NSString).range(of: minimunStaking))
                    
        return attr
    }
            
    static func stakingFaq() -> (string: NSMutableAttributedString, faqRange: NSRange) {
                            
        let faq = Localizable.Waves.Staking.Landing.Faq.Part.two
        let fullText = Localizable.Waves.Staking.Landing.Faq.Part.one(Localizable.Waves.Staking.Landing.Faq.Part.two)
        
        let attr = NSMutableAttributedString(string: fullText)
        
        attr.addAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .regular),
                            .foregroundColor: UIColor.basic500],
                           range: .init(location: 0, length: attr.string.count))
        
        let faqRange = (attr.string as NSString).range(of: faq)
        
        
        attr.addAttributes([.font: UIFont.systemFont(ofSize: 12),
                            .foregroundColor: UIColor.submit400,
                            NSAttributedString.Key.underlineStyle: NSNumber(value: false)],
                           range: faqRange)
                    
        return (string: attr, faqRange: faqRange)
    }
}

//MARK: UIScrollViewDelegate

extension WalletStakingLandingCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = scrollView.currentPage
        ifNeedUpdateNextButton()
    }
}

//MARK: UIScrollViewDelegate

extension WalletStakingLandingCell: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        guard let url = url else { return }
        
        self.didSelectLinkWith?(url)
    }
}



