//
//  NewHistoryViewController.swift
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

final class NewHistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: WalletSegmentedControl!
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    var presenter: HistoryPresenterProtocol!
    
    private var sections: [HistoryTypes.ViewModel.Section] = []
    private var filters: [HistoryTypes.Filter] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Localizable.History.Navigationbar.title

        setupSystem()
        setupSegmentedControl()
        createMenuButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = UIColor.basic50
        setupTopBarLine()
        setupBigNavigationBar()
        if rdv_tabBarController.isTabBarHidden {
            rdv_tabBarController.setTabBarHidden(false, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupTopBarLine()
    }
}

// MARK: Bind UI

private extension NewHistoryViewController {
    
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
        
        let changedDisplayEvent = segmentedControl.changedValue()
            .map { [weak self] selectedIndex -> HistoryTypes.Event in
                
                let filter = self?.filters[selectedIndex] ?? .all
                return .changeFilter(filter)
        }
        
        return [changedDisplayEvent]
    }
    
    func uiSubscriptions(state: Driver<HistoryTypes.State>) -> [Disposable] {
        
        let subscriptionSections = state
            .drive(onNext: { [weak self] (state) in
            
            guard let strongSelf = self else { return }
                
            
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
                
                
            }, completion: { _ in })
        })
        
        return [subscriptionSections]
    }
    
}

// MARK: - Setup

extension NewHistoryViewController {
    
    func setupSegmentedControl() {
        let buttons = filters.map { SegmentedControl.Button(name: $0.name) }
        segmentedControl
            .segmentedControl
            .update(with: buttons, animated: true)
    }
    
    func changeFilter(_ filter: HistoryTypes.Filter) {
//        segmentedControl.select
        // тута меняем segmented
        segmentedControl.segmentedControl.selectedIndex = filters.index(of: filter) ?? 0
    }
    
}

extension NewHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let row = sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .transactionSkeleton:
            let skeletonCell: WalletAssetSkeletonCell = cell as! WalletAssetSkeletonCell
            skeletonCell.slide(to: .right)
            
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
      let row = sections[indexPath.section].items[indexPath.row]
        
        switch row {
        case .transactionSkeleton:
            return WalletAssetSkeletonCell.cellHeight()
            
        case .transaction:
            return HistoryAssetCell.cellHeight()
        }

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return WalletHeaderView.viewHeight()
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

extension NewHistoryViewController: UITableViewDataSource {
    
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
            let cell: WalletAssetSkeletonCell = tableView.dequeueCell()
            return cell
            
        case .transaction(let transaction):
            let cell: HistoryAssetCell = tableView.dequeueCell()
            cell.update(with: transaction)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let model = sections[section]
        
        let view: WalletHeaderView = tableView.dequeueAndRegisterHeaderFooter()
        
        guard let firstItem = model.items.first else { return view }
        
        
        switch firstItem {
        case .transaction(let transaction):
            if let header = model.header {
                view.update(with: header)
            } else {
                let date = transaction.date as Date
                let d = date.toFormat("dd MMM yyyy", locale: Locales.current)
                view.update(with: d)
            }
        default:
            break
        }
        
        return view
    }

    
}

extension NewHistoryViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
    
}
