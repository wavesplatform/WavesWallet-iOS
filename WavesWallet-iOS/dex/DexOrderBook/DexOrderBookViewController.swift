//
//  DexOrderBookViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback



private enum Constants {
    static let buttonTitleSize: CGFloat = 10
    static let buttonSubTitleSize: CGFloat = 13
    static let buttonLineSpacing: CGFloat = 3
    static let headerCornerRadius: CGFloat = 3
}

final class DexOrderBookViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonBuy: UIButton!
    @IBOutlet weak var buttonSell: UIButton!
    @IBOutlet weak var viewTopHeader: DexOrderBookHeaderView!
    @IBOutlet weak var labelLoadingOrderBook: UILabel!
    
    @IBOutlet weak var viewLoading: UIView!
    @IBOutlet weak var viewEmptyData: UIView!
    
    
    var presenter: DexOrderBookPresenterProtocol!
    private let sendEvent: PublishRelay<DexOrderBook.Event> = PublishRelay<DexOrderBook.Event>()
    
    var hasInit = false
    
    var bids: [DexOrderBook.DTO.BidAsk] = []
    var asks: [DexOrderBook.DTO.BidAsk] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtonsWithEmptyValues()
        setupLocalization()
        
        viewTopHeader.setWhiteState()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.hasInit = true
            self.viewTopHeader.setDefaultState()
            self.viewLoading.isHidden = true
            self.tableView.reloadData()            
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .middle, animated: false)
        }
        
        
        let feedback = bind(self) { owner, state -> Bindings<DexOrderBook.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }
        
        let readyViewFeedback: DexOrderBookPresenter.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.rx.viewWillAppear.take(1).map { _ in DexOrderBook.Event.readyView }.asSignal(onErrorSignalWith: Signal.empty())
        }
        
        presenter.system(feedbacks: [feedback, readyViewFeedback])
        
        loadTestData()
    }
    
    func loadTestData() {

        
        
//        let bid = DexOrderBook.DTO.BidAsk(price: 32050, amount: 237499500000, amountAssetDecimal: 8, priceAssetDecimal: 8)
        
//        print("price",MoneyUtil.getScaledText(bid.price, decimals: bid.priceAssetDecimal, scale: bid.defaultScaleDecimal + bid.priceAssetDecimal - bid.amountAssetDecimal))

//        print("amount", MoneyUtil.getScaledTextTrimZeros(bid.amount, decimals: bid.amountAssetDecimal))

        
//        cell.labelPrice.text = MoneyUtil.getScaledText(item["price"] as! Int64, decimals: priceAssetDecimal, scale: 8 + priceAssetDecimal - amountAssetDecimal)
//        cell.labelSell.text = MoneyUtil.getScaledTextTrimZeros(item["amount"] as! Int64, decimals: amountAssetDecimal)

    }
}

// MARK: Feedback
fileprivate extension DexOrderBookViewController {
    func events() -> [Signal<DexOrderBook.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<DexOrderBook.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                debug(state.action)

                
                guard let strongSelf = self else { return }
                guard state.action != .none else { return }
                
                
                strongSelf.tableView.reloadData()
            })
        
        return [subscriptionSections]
    }
}


//MARK: - UITableViewDelegate
extension DexOrderBookViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

//MARK: - UITableViewDataSource
extension DexOrderBookViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !hasInit {
            return 0
        }
        if section == 1 {
            return 1
        }
        else if section == 0 {
            
        }
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.section == 1 {
            let cell = tableView.dequeueCell() as DexOrderBookLastPriceCell
            
            let model = DexOrderBookLastPriceCell.Model(price: "0.3144", percent: "23", isSell: true)
            cell.update(with: model)
            return cell
        }
        let cell = tableView.dequeueCell() as DexOrderBookCell
        
//        let model = DexOrderBookCell.Model(amount: "0.4314", price: "0.43141", sum: "3143.13", isSell: false, percentAmountOverlay: Float(arc4random() % 100))
//        cell.update(with: model)
        return cell
    }
}


//MARK: - SetupUI
private extension DexOrderBookViewController {
    
    func setupLocalization() {
        labelLoadingOrderBook.text = Localizable.DexOrderBook.Label.loadingOrderbook
    }
    
    func setupButtonsWithEmptyValues() {
        setupButton(buttonBuy, title: Localizable.DexOrderBook.Button.buy, subTitle: "—")
        setupButton(buttonSell, title: Localizable.DexOrderBook.Button.sell, subTitle: "—")
    }
    
    func setupButton(_ button: UIButton, title: String, subTitle: String) {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = Constants.buttonLineSpacing
        paragraph.alignment = .center
        
        let attributes =  [NSAttributedStringKey.font : UIFont.systemFont(ofSize: Constants.buttonSubTitleSize, weight: .semibold),
                           NSAttributedStringKey.foregroundColor : UIColor.white,
                           NSAttributedStringKey.paragraphStyle : paragraph]
        
        let text = title + "\n" + subTitle
        let attrString = NSMutableAttributedString(string: text, attributes: attributes)
        attrString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: Constants.buttonTitleSize), range: (text as NSString).range(of: title))
        
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.attributedText = attrString
        button.setAttributedTitle(attrString, for: .normal)
    }
}
