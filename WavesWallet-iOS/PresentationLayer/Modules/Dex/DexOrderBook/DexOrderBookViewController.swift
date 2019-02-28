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

private enum Constansts {
    static let emptyButtonsTitle: String = "0.000"
    static let loadingButtonsTitle: String = "—"
    static let updateTime: RxTimeInterval = 20
}

final class DexOrderBookViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var buttonBuy: DexTraderContainerButton!
    @IBOutlet private weak var buttonSell: DexTraderContainerButton!
    @IBOutlet private weak var viewTopHeader: DexOrderBookHeaderView!
    @IBOutlet private weak var labelLoadingOrderBook: UILabel!
    
    @IBOutlet private weak var viewLoading: UIView!
    @IBOutlet private weak var viewEmptyData: UIView!
    @IBOutlet private weak var labelEmptyData: UILabel!
    
    var presenter: DexOrderBookPresenterProtocol!
    private let sendEvent: PublishRelay<DexOrderBook.Event> = PublishRelay<DexOrderBook.Event>()
    private var state: DexOrderBook.State = DexOrderBook.State.initialState
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSellBuyButtons()
        setupLocalization()
        setupLoadingState()
        setupFeedBack()
    }
}

//MARK: - DexTraderContainerProcotol
extension DexOrderBookViewController: DexTraderContainerProcotol {
    
    func controllerWillAppear() {
        sendEvent.accept(.updateData)
        Observable<Int>.interval(Constansts.updateTime, scheduler: MainScheduler.asyncInstance).subscribe(onNext: { [weak self] (value) in
            self?.sendEvent.accept(.updateData)
        }).disposed(by: disposeBag)
    }
    
    func controllerWillDissapear() {
        disposeBag = DisposeBag()
    }
}

//MARK: - DexCreateOrderProtocol, DexCancelOrderProtocol

extension DexOrderBookViewController: DexCreateOrderProtocol, DexCancelOrderProtocol {
    
    func updateCanceledOrders() {
        sendEvent.accept(.updateData)
    }
    
    func updateCreatedOrders() {
        sendEvent.accept(.updateData)
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
            sendEvent.accept(.didTapBid(bid, inputMaxAmount: false))
        }
        else if state.hasFirstTimeLoad {
            sendEvent.accept(.didTapEmptyBid)
        }
    }
    
    @IBAction func buyTapped(_ sender: Any) {
        if let ask = state.lastAsk {
            sendEvent.accept(.didTapAsk(ask, inputMaxAmount: false))
        }
        else if state.hasFirstTimeLoad {
            sendEvent.accept(.didTamEmptyAsk)
        }
    }
}

//MARK: - UITableViewDelegate
extension DexOrderBookViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = state.sections[indexPath.section].items[indexPath.row]
        if let bid = row.bid {
            sendEvent.accept(.didTapBid(bid, inputMaxAmount: true))
        }
        else if let ask = row.ask {
            sendEvent.accept(.didTapAsk(ask, inputMaxAmount: true))
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
        viewTopHeader.update(with: state.header)

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
        buttonBuy.setup(title: Localizable.Waves.Dexorderbook.Button.buy, subTitle: askTitle)
        buttonSell.setup(title: Localizable.Waves.Dexorderbook.Button.sell, subTitle: bidTitle)
    }
    
    func setupLocalization() {
        labelLoadingOrderBook.text = Localizable.Waves.Dexorderbook.Label.loadingOrderbook
        labelEmptyData.text = Localizable.Waves.Dexorderbook.Label.emptyData
    }
}

//MARK: - UI Settings
private extension DexOrderBookViewController {
    
    var bidTitle: String {
        if let bid = state.lastBid {
            return bid.price.displayText
        }
        else if !state.hasFirstTimeLoad {
            return Constansts.loadingButtonsTitle
        }
        return Constansts.emptyButtonsTitle
    }
    
    var askTitle: String {
        if let ask = state.lastAsk {
            return ask.price.displayText
        }
        else if !state.hasFirstTimeLoad {
            return Constansts.loadingButtonsTitle
        }
        return Constansts.emptyButtonsTitle
    }
}
