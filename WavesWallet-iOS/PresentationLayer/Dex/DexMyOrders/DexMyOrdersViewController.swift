//
//  DexMyOrdersViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/15/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

fileprivate enum Constants {
    static let cornerTableRadius: CGFloat = 3
}

final class DexMyOrdersViewController: UIViewController {

    @IBOutlet private weak var labelDate: UILabel!
    @IBOutlet private weak var labelSidePrice: UILabel!
    @IBOutlet private weak var labelAmountSum: UILabel!
    @IBOutlet private weak var labelStatus: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var viewEmptyData: UIView!
    @IBOutlet private weak var viewLoadingInfo: UIView!
    @IBOutlet private weak var labelLoadingData: UILabel!
    @IBOutlet private weak var labelEmptyData: UILabel!
    
    private var section = DexMyOrders.ViewModel.Section(items: [])
    var presenter: DexMyOrdersPresenterProtocol!
    private let sendEvent: PublishRelay<DexMyOrders.Event> = PublishRelay<DexMyOrders.Event>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFeedBack()
        setupLocalization()
        setupLoadingState()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        headerView.createTopCorners(radius: Constants.cornerTableRadius)
    }
}

// MARK: Feedback

fileprivate extension DexMyOrdersViewController {
    
    func setupFeedBack() {
        
        let feedback = bind(self) { owner, state -> Bindings<DexMyOrders.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }
        
        let readyViewFeedback: DexMyOrdersPresenter.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.rx.viewWillAppear.take(1).map { _ in DexMyOrders.Event.readyView }.asSignal(onErrorSignalWith: Signal.empty())
        }
        presenter.system(feedbacks: [feedback, readyViewFeedback])
    }
    
    func events() -> [Signal<DexMyOrders.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<DexMyOrders.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                guard let strongSelf = self else { return }
                switch state.action {
                case .none:
                    return
                default:
                    break
                }
                
                strongSelf.section = state.section

                switch state.action {
                case .update:
                    strongSelf.tableView.reloadData()
                    
                case .deleteRow(let indexPath):
                    strongSelf.deleteAt(indexPath: indexPath)

                default:
                    break
                }
               
                strongSelf.setupDefaultState()
            })
        
        return [subscriptionSections]
    }
}

//MARK: - Actions
private extension DexMyOrdersViewController {
    
    func deleteAt(indexPath: IndexPath) {
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.tableView.reloadData()
        })
        tableView.deleteRows(at: [indexPath], with: .fade)
        CATransaction.commit()
    }
}

//MARK: - UITableViewDataSource
extension DexMyOrdersViewController: UITableViewDataSource {
    


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.section.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = section.items[indexPath.row]

        switch row {
        case .order(let myOrder):
            let cell = tableView.dequeueCell() as DexMyOrdersCell
            cell.update(with: myOrder)
            
            cell.buttonDeleteDidTap = { [weak self] in
                self?.sendEvent.accept(.didRemoveOrder(indexPath))
            }
            return cell
        }
    }
}

//MARK: - SetupUI

private extension DexMyOrdersViewController {
    
    func setupLoadingState() {
        viewEmptyData.isHidden = true
        headerView.isHidden = true
    }
    
    func setupDefaultState() {
        viewLoadingInfo.isHidden = true
        viewEmptyData.isHidden = section.items.count > 0
        headerView.isHidden = section.items.count == 0
    }
    
    func setupLocalization() {
        labelEmptyData.text = Localizable.Waves.Dexmyorders.Label.emptyData
        labelLoadingData.text = Localizable.Waves.Dexmyorders.Label.loadingLastTrades
        labelDate.text = Localizable.Waves.Dexmyorders.Label.date
        labelSidePrice.text = Localizable.Waves.Dexmyorders.Label.side + "/" + Localizable.Waves.Dexmyorders.Label.price
        labelAmountSum.text = Localizable.Waves.Dexmyorders.Label.amount + "/" + Localizable.Waves.Dexmyorders.Label.sum
        labelStatus.text = Localizable.Waves.Dexmyorders.Label.status
    }
}
