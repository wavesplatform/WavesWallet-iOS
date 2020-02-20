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

final class StakingLandingCell: MinHeightTableViewCell, NibReusable {

    @IBOutlet private weak var blueTopView: UIView!
    @IBOutlet private weak var labelEarnPercent: UILabel!
    @IBOutlet private weak var labelAnnualInterests: UILabel!
    @IBOutlet private weak var labelMoney: UILabel!
    @IBOutlet private weak var labelProfitStaking: UILabel!
    @IBOutlet private weak var buttonNext: HighlightedButton!
    @IBOutlet private weak var labelHowItWorks: UILabel!
    @IBOutlet private weak var faqLabel: TTTAttributedLabel!
    
    @IBOutlet private weak var firstInfoView: StakingLadingInfoView!
    @IBOutlet private weak var secondInfoView: StakingLadingInfoView!
    @IBOutlet private weak var thirdInfoView: StakingLadingInfoView!
    @IBOutlet private weak var pageControl: PageControl!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    private let shapeLayer = CAShapeLayer()
        
    private var model: Model? = nil
    
    private static var totalProfitValue: Double? = nil
    private var profitValue: Double? = nil
    private var deffaultProfitValue: Double? = nil
    
    public var startStaking: (() -> Void)?
    
    public var didSelectLinkWith: ((URL) -> Void)?
    
    private var isLastPage: Bool {
        return scrollView.currentPage == (scrollView.maxPages - 1)
    }
    
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
                                
        let totalProfitValue = StakingLandingCell.totalProfitValue
        let money: Double = profitValue + (totalProfitValue ?? 0)
        
        StakingLandingCell.totalProfitValue = money
        
        let minimumDeposit =  model.minimumDeposit.money
        let deffaultProfitValue = self.deffaultProfitValue ?? 0
        let amount = Int64((money + deffaultProfitValue) * pow(10, Double(minimumDeposit.decimals)))
                                
        let totalValue = Money(amount,
                               minimumDeposit.decimals)
        
                
        labelMoney.attributedText = NSMutableAttributedString.stakingProfit(totalValue: totalValue)
    }
    
    @IBAction private func nextTapped(_ sender: Any) {
        if isLastPage {
            startStaking?()
        } else {
            scrollView.nextPage()
        }
    }
    
    private func ifNeedUpdateNextButton() {
                        
        if isLastPage == false {
            buttonNext.setTitle(Localizable.Waves.Staking.Landing.next, for: .normal)
        } else {
            buttonNext.setTitle(Localizable.Waves.Staking.Landing.startStaking, for: .normal)
        }
    }
}

// MARK: Localization
extension StakingLandingCell: Localization {
    
    func setupLocalization() {
        
        firstInfoView.titleLabel.text = Localizable.Waves.Staking.Landing.Slide.Buyusdn.title
        firstInfoView.subTitleLabel.text = Localizable.Waves.Staking.Landing.Slide.Buyusdn.subtitle
        
        secondInfoView.titleLabel.text = Localizable.Waves.Staking.Landing.Slide.Depositusdn.title
        secondInfoView.subTitleLabel.text = Localizable.Waves.Staking.Landing.Slide.Depositusdn.subtitle
        
        thirdInfoView.titleLabel.text = Localizable.Waves.Staking.Landing.Slide.Passiveincome.title
        thirdInfoView.subTitleLabel.text = Localizable.Waves.Staking.Landing.Slide.Passiveincome.subtitle
        
    }
}

// MARK: ViewConfiguration

extension StakingLandingCell: ViewConfiguration {
        
    func update(with model: WalletTypes.DTO.Staking.Landing) {
        
        self.model = model
                
        let minimumDeposit = model.minimumDeposit.money
        let deffaultProfitValue = minimumDeposit.doubleValue * (model.percent / 100)
                    
        self.deffaultProfitValue = deffaultProfitValue
        self.profitValue = (deffaultProfitValue / Constants.secondYear) / 10
                        
        labelEarnPercent.attributedText = NSMutableAttributedString.stakingEarnPercent(percent: model.percent)
        labelAnnualInterests.text = Localizable.Waves.Staking.Landing.annualInterest
                                    
        labelProfitStaking.attributedText = NSMutableAttributedString.stakingProfitInfo(minimumDeposit: minimumDeposit)
        labelHowItWorks.text = Localizable.Waves.Staking.Landing.howItWorks
        
        let faq = NSMutableAttributedString.stakingFaq()
        faqLabel.attributedText = faq.string
        faqLabel.delegate = self
        
        if let url = URL(string: UIGlobalConstants.URL.stakingFaq) {
            faqLabel.activeLinkAttributes = NSMutableAttributedString.stakingFaqAttributted()
            faqLabel.linkAttributes = NSMutableAttributedString.stakingFaqAttributted()
            faqLabel.addLink(to: url, with: faq.faqRange)
        }
        
        setupLocalization()
        ifNeedUpdateNextButton()
    }
}

//MARK: UIScrollViewDelegate

extension StakingLandingCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = scrollView.currentPage
        ifNeedUpdateNextButton()
    }
}

//MARK: UIScrollViewDelegate

extension StakingLandingCell: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        guard let url = url else { return }
        
        self.didSelectLinkWith?(url)
    }
}

// MARK: NSMutableAttributedString

fileprivate extension NSMutableAttributedString {
    
    static func stakingEarnPercent(percent: Double) -> NSMutableAttributedString {
                
        let percent = String(format: "%.02f", percent)
        let earnPercent = Localizable.Waves.Staking.Landing.earn(percent + "%")
        let attr = NSMutableAttributedString(string: earnPercent)
        
        attr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.submit300],
                           range: (attr.string as NSString).range(of: percent))
        
        return attr
    }
    
    static func stakingProfit(totalValue: Money) -> NSMutableAttributedString {
                                               
        let attr = NSMutableAttributedString(string: "$" + totalValue.displayTextFull(isFiat: true))
        attr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.submit300],
                           range: (attr.string as NSString).range(of: totalValue.displayTextFull(isFiat: true)))
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
    
    static func stakingFaqAttributted() -> [NSAttributedString.Key: Any] {
        
        return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                NSAttributedString.Key.foregroundColor: UIColor.submit400,
                NSAttributedString.Key.underlineStyle: NSNumber(value: false)]
    }
            
    static func stakingFaq() -> (string: NSMutableAttributedString, faqRange: NSRange) {
                            
        let faq = Localizable.Waves.Staking.Landing.Faq.Part.two
        let fullText = Localizable.Waves.Staking.Landing.Faq.Part.one(Localizable.Waves.Staking.Landing.Faq.Part.two)
        
        let attr = NSMutableAttributedString(string: fullText)
        
        attr.addAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .regular),
                            .foregroundColor: UIColor.basic500],
                           range: .init(location: 0, length: attr.string.count))
        
        let faqRange = (attr.string as NSString).range(of: faq)
                
        attr.addAttributes(NSMutableAttributedString.stakingFaqAttributted(),
                           range: faqRange)
                    
        return (string: attr, faqRange: faqRange)
    }
}
