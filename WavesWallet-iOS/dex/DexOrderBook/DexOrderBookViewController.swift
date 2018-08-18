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
    private var state: DexOrderBook.State = DexOrderBook.State.initialState
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSellBuyButtons()
        setupLocalization()
        setupLoadingState()
        setupFeedBack()
    }
}

// MARK: Feedback

fileprivate extension DexOrderBookViewController {

    func setupFeedBack() {
        
        let feedback = bind(self) { owner, state -> Bindings<DexOrderBook.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }
        
        let readyViewFeedback: DexOrderBookPresenter.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.rx.viewWillAppear.take(1).map { _ in DexOrderBook.Event.readyView }.asSignal(onErrorSignalWith: Signal.empty())
        }
        presenter.system(feedbacks: [feedback, readyViewFeedback])
    }
    
    func events() -> [Signal<DexOrderBook.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<DexOrderBook.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                                
                guard let strongSelf = self else { return }
                guard state.action != .none else { return }
                
                strongSelf.state = state
                strongSelf.tableView.reloadData()
                strongSelf.setupSellBuyButtons()
                strongSelf.setupDefaultState(state: state)
            })
        
        return [subscriptionSections]
    }
}

//MARK: - Actions
private extension DexOrderBookViewController {
    
    @IBAction func sellTapped(_ sender: Any) {
        if let bid = state.lastBid {
            sendEvent.accept(.didTapBid(bid))
        }
    }
    
    @IBAction func buyTapped(_ sender: Any) {
        if let ask = state.lastAsk {
            sendEvent.accept(.didTapAsk(ask))
        }
    }
}

//MARK: - UITableViewDelegate
extension DexOrderBookViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = state.sections[indexPath.section].items[indexPath.row]
        if let bid = row.bid {
            sendEvent.accept(.didTapBid(bid))
        }
        else if let ask = row.ask {
            sendEvent.accept(.didTapAsk(ask))
        }
    }
}

//MARK: - UITableViewDataSource
extension DexOrderBookViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return state.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let row = state.sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .ask(let ask):
            return updateAskBidCell(ask)
            
        case .bid(let bid):
            return updateAskBidCell(bid)

        case .lastPrice(let lastPrice):
            let cell = tableView.dequeueCell() as DexOrderBookLastPriceCell
            cell.update(with: lastPrice)
            return cell
        }
    }
}


//MARK: - Cells
private extension DexOrderBookViewController {
    
    func updateAskBidCell(_ askBid: DexOrderBook.DTO.BidAsk) -> DexOrderBookCell {
        let cell = tableView.dequeueCell() as DexOrderBookCell
        cell.update(with: askBid)
        return cell
    }
}

//MARK: - SetupUI
private extension DexOrderBookViewController {
    
    func setupDefaultState(state: DexOrderBook.State) {
        
        viewLoading.isHidden = true
        viewEmptyData.isHidden = state.isNotEmpty

        if state.isNotEmpty {
            viewTopHeader.setDefaultState()
            
            if let sectionLastPrice = state.lastPriceSection,
                state.action == .scrollTableToCenter {
                tableView.scrollToRow(at: IndexPath(row: 0, section: sectionLastPrice), at: .middle, animated: false)
            }
        }
    }
    
    func setupLoadingState() {
        viewTopHeader.setWhiteState()
        viewEmptyData.isHidden = true
    }
    
    func setupSellBuyButtons() {
        setupButton(buttonBuy, title: Localizable.DexOrderBook.Button.buy, subTitle: askTitle)
        setupButton(buttonSell, title: Localizable.DexOrderBook.Button.sell, subTitle: bidTitle)
    }
    
    func setupLocalization() {
        labelLoadingOrderBook.text = Localizable.DexOrderBook.Label.loadingOrderbook
    }
}

//MARK: - UI Settings
private extension DexOrderBookViewController {
    
    var bidTitle: String {
        if let bid = state.lastBid {
            return bid.priceText
        }
        return "—"
    }
    
    var askTitle: String {
        if let ask = state.lastAsk {
            return ask.priceText
        }
        return "—"
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
