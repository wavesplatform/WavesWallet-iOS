//
//  HistoryViewController.swift
//  WavesWallet-iOS
//
//  Created by Mac on 02/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxCocoa
import RxDataSources
import RxFeedback
import RxSwift
import SwiftDate

fileprivate enum Constants {
    static let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0 )
}

final class HistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: WalletSegmentedControl!
    private var refreshControl: UIRefreshControl!
    
    private let disposeBag: DisposeBag = DisposeBag()
    private var isRefreshing: Bool = false
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyTextLabel: UILabel!
    
    var presenter: HistoryPresenterProtocol!
    
    private var sections: [HistoryTypes.ViewModel.Section] = []
    private var filters: [HistoryTypes.Filter] = []
    
    let tapCell: PublishSubject<DomainLayer.DTO.SmartTransaction> = PublishSubject<DomainLayer.DTO.SmartTransaction>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = Localizable.History.Navigationbar.title
        
        tableView.contentInset = Constants.contentInset
        emptyView.isHidden = true
        emptyTextLabel.text = Localizable.Asset.Header.notHaveTransactions
        
        setupSegmentedControl()
        setupRefreshControl()
        setupSystem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = UIColor.basic50
        setupTopBarLine()
        setupBigNavigationBar()
//        if rdv_tabBarController.isTabBarHidden {
//            rdv_tabBarController.setTabBarHidden(false, animated: true)
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupTopBarLine()
    }
}

// MARK: Bind UI

private extension HistoryViewController {
    
    func setupSystem() {
        
        let feedback: HistoryPresenterProtocol.Feedback = bind(self) { owner, state in
            
            let subscriptions = owner.uiSubscriptions(state: state)
            let events = owner.events()
            
            return Bindings(subscriptions: subscriptions,
                            events: events)
        }
        
        let readyViewFeedback: HistoryPresenter.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .rx
                .viewWillAppear
                .take(1)
                .map { _ in HistoryTypes.Event.readyView }
                .asSignal(onErrorSignalWith: Signal.empty())
        }
        
        presenter.system(feedbacks: [feedback,
                                     readyViewFeedback])
        
    }
    
    func events() -> [Signal<HistoryTypes.Event>] {

        let refreshEvent = tableView
            .rx
            .didRefreshing(refreshControl: refreshControl)
            .map { _ in HistoryTypes.Event.refresh }
            .asSignal(onErrorSignalWith: Signal.empty())

        
        let tap = tableView
            .rx
            .itemSelected
            .map { indexPath -> HistoryTypes.Event in
                return HistoryTypes.Event.tapCell(indexPath) 
            }
            .asSignal(onErrorSignalWith: Signal.empty())

        let changedDisplayEvent = segmentedControl.changedValue()
            .map { [weak self] selectedIndex -> HistoryTypes.Event in
                
                let filter = self?.filters[selectedIndex] ?? .all
                return .changeFilter(filter)
        }
        
        return [changedDisplayEvent, refreshEvent, tap]
    }
    
    func uiSubscriptions(state: Driver<HistoryTypes.State>) -> [Disposable] {
        
        let subscriptionSections = state
            .drive(onNext: { [weak self] (state) in
            
                guard let strongSelf = self else { return }
            
                strongSelf.emptyView.isHidden = state.sections.count > 0
                
                if (!strongSelf.filters.elementsEqual(state.filters)) {
                    strongSelf.filters = state.filters
                    strongSelf.setupSegmentedControl()
                    strongSelf.changeFilter(state.currentFilter)
                }
                
                strongSelf.sections = state.sections
            
                UIView.transition(with: strongSelf.tableView,
                                  duration: 0.24,
                                  options: [.transitionCrossDissolve, .curveEaseInOut],
                                  animations: {
                                    
                                    strongSelf.tableView.reloadData()
                                    
                                    
                }, completion: { _ in
                    
                    if (!state.isRefreshing && strongSelf.isRefreshing) {
                        strongSelf.refreshControl.endRefreshing()
                    }
                    
                    strongSelf.isRefreshing = state.isRefreshing
                    
                })
                
        })
        
        return [subscriptionSections]
    }
    
}

// MARK: - Setup

extension HistoryViewController {
    
    func setupSegmentedControl() {
        let buttons = filters.map { SegmentedControl.Button(name: $0.name) }
        segmentedControl
            .segmentedControl
            .update(with: buttons, animated: true)
    }
    
    func changeFilter(_ filter: HistoryTypes.Filter) {
        segmentedControl.segmentedControl.selectedIndex = filters.index(of: filter) ?? 0
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }

    
}

extension HistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .transaction(let transaction):
            
            self.tapCell.onNext(transaction)
            
        default: break
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let row = sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .transactionSkeleton:
            let skeletonCell: HistoryTransactionSkeletonCell = cell as! HistoryTransactionSkeletonCell
            skeletonCell.slide(to: .right)
            
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let model = sections[section]
        
        guard let firstItem = model.items.first else { return }
        
        switch firstItem {
        case .transactionSkeleton:
            (view as! HeaderSkeletonView).slide(to: .right)
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
      let row = sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .transactionSkeleton:
            return HistoryTransactionSkeletonCell.cellHeight()
            
        case .transaction:
            return HistoryTransactionCell.cellHeight()
        }

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HistoryHeaderView.viewHeight()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.minValue
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.minValue
    }
    
}

extension HistoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = sections[indexPath.section].items[indexPath.item]
        
        switch item {
        case .transactionSkeleton:
            let cell: HistoryTransactionSkeletonCell = tableView.dequeueCell()
            return cell
            
        case .transaction(let transaction):
            let cell: HistoryTransactionCell = tableView.dequeueAndRegisterCell()
            cell.update(with: transaction)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let model = sections[section]
        
        guard let firstItem = model.items.first else { return nil }
        
        switch firstItem {
        case .transaction:
            
            let view: HistoryHeaderView = tableView.dequeueAndRegisterHeaderFooter()
            
            if let header = model.header {
                view.update(with: header)
            }
            return view

        case .transactionSkeleton:
            
            let view: HeaderSkeletonView = tableView.dequeueAndRegisterHeaderFooter()
            
            return view
            
        }
    }
}

extension HistoryViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
    
}
