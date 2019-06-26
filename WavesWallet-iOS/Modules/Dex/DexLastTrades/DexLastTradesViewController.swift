//
//  DexLastTradesViewController.swift
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
}

final class DexLastTradesViewController: UIViewController {

    @IBOutlet private weak var headerView: DexLastTradesHeaderView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var viewLoading: UIView!
    @IBOutlet private weak var buttonBuy: DexTraderContainerButton!
    @IBOutlet private weak var buttonSell: DexTraderContainerButton!
    @IBOutlet private weak var viewEmptyData: UIView!
    @IBOutlet private weak var labelEmptyData: UILabel!
    @IBOutlet private weak var labelLoading: UILabel!
    private var refreshControl: UIRefreshControl!

    var presenter: DexLastTradesPresenterProtocol!
    private let sendEvent: PublishRelay<DexLastTrades.Event> = PublishRelay<DexLastTrades.Event>()
    private var state: DexLastTrades.State = DexLastTrades.State.initialState
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSellBuyButtons()
        setupLocalization()
        setupLoadingState()
        setupFeedBack()
        setupRefreshControl()
    }
}


// MARK: Feedback
fileprivate extension DexLastTradesViewController {
    
    func setupFeedBack() {
        
        let feedback = bind(self) { owner, state -> Bindings<DexLastTrades.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }
        
        let readyViewFeedback: DexLastTradesPresenter.Feedback = { [weak self] _ in
            guard let self = self else { return Signal.empty() }
            return self.rx.viewWillAppear.take(1).map { _ in DexLastTrades.Event.readyView }.asSignal(onErrorSignalWith: Signal.empty())
        }
        presenter.system(feedbacks: [feedback, readyViewFeedback])
    }
    
    func events() -> [Signal<DexLastTrades.Event>] {
        
        let refresh = refreshControl.rx.controlEvent(.valueChanged).map { DexLastTrades.Event.refresh }.asSignal(onErrorSignalWith: Signal.empty())

        return [sendEvent.asSignal(), refresh]
    }
    
    func subscriptions(state: Driver<DexLastTrades.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                guard let self = self else { return }
                guard state.action != .none else { return }
                
                self.state = state
                self.tableView.reloadData()
                self.setupSellBuyButtons()
                self.setupDefaultState(state: state)
                self.refreshControl.endRefreshing()
            })
        
        return [subscriptionSections]
    }
}

//MARK: - UITableViewDataSource
extension DexLastTradesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.section.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = state.section.items[indexPath.row]
        switch row {
        case .trade(let trade):
            let cell = tableView.dequeueCell() as DexLastTradesCell
            cell.update(with: trade)
            return cell
        }
    }
}

//MARK: - Actions

private extension DexLastTradesViewController {
    
    @IBAction func sellTapped(_ sender: Any) {
        if let sell = state.lastSell {
            sendEvent.accept(.didTapSell(sell))
        }
        else if state.hasFirstTimeLoad {
            sendEvent.accept(.didTapEmptySell)
        }
    }
    
    @IBAction func buyTapped(_ sender: Any) {
        if let buy = state.lastBuy {
            sendEvent.accept(.didTapBuy(buy))
        }
        else if state.hasFirstTimeLoad {
            sendEvent.accept(.didTapEmptyBuy)
        }
    }
}

//MARK: - SetupUI

private extension DexLastTradesViewController {
    
    func setupRefreshControl() {
        if #available(iOS 10.0, *) {
            refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
    
    func setupLocalization() {
        labelEmptyData.text = Localizable.Waves.Dexlasttrades.Label.emptyData
        labelLoading.text = Localizable.Waves.Dexlasttrades.Label.loadingLastTrades
    }
    
    func setupLoadingState() {
        headerView.setWhiteState()
        viewEmptyData.isHidden = true
    }
    
    func setupDefaultState(state: DexLastTrades.State) {
        
        viewLoading.isHidden = true
        viewEmptyData.isHidden = state.isNotEmpty
        
        if state.isNotEmpty {
            headerView.setDefaultState()
        }
    }
    
    func setupSellBuyButtons() {
        buttonBuy.setup(title: Localizable.Waves.Dexlasttrades.Button.buy, subTitle: buyTitle)
        buttonSell.setup(title: Localizable.Waves.Dexlasttrades.Button.sell, subTitle: sellTitle)
    }
}



//MARK: - UI Settings
private extension DexLastTradesViewController {
    
    var sellTitle: String {
        if let sell = state.lastSell {
            return sell.price.displayText
        }
        else if !state.hasFirstTimeLoad {
            return Constansts.loadingButtonsTitle
        }
        return Constansts.emptyButtonsTitle
    }
    
    var buyTitle: String {
        if let buy = state.lastBuy {
            return buy.price.displayText
        }
        else if !state.hasFirstTimeLoad {
            return Constansts.loadingButtonsTitle
        }
        return Constansts.emptyButtonsTitle
    }
}
