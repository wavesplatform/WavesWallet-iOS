//
//  PaymentHistoryVC.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 04.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import RxCocoa
import RxSwift
import UIKit

class PayoutsHistoryVC: UIViewController {
    
    var system: System<PayoutsHistoryState, PayoutsHistoryEvents>?
    
    @IBOutlet private weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    private var payoutsHistoryVMs: [PayoutsHistoryState.UI.PayoutTransactionVM] = []
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        
        system?
            .start()
            .drive(onNext: { [weak self] state in self?.bindUI(state.ui) })
            .disposed(by: disposeBag)
    }
    
    private func initialSetup() {
        
        createBackButton()
        setupBigNavigationBar()
        
        navigationItem.title = "Payouts History"
        navigationItem.barTintColor = .white
        
        do {
            refreshControl
                .rx
                .controlEvent(.valueChanged)
                .subscribe(onNext: { [weak self] in self?.system?.send(.pullToRefresh) })
                .disposed(by: disposeBag)
            
            tableView.refreshControl = refreshControl
            tableView.registerCell(type: PayoutsTransactionCell.self)
            
            tableView.contentInset.bottom = Constants.tableViewBottomContentInset
            tableView.separatorStyle = .none
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    private func bindUI(_ state: PayoutsHistoryState.UI) {
        refreshControl.endRefreshing()
        
        switch state.state {
        case .dataLoaded:
            self.payoutsHistoryVMs = state.viewModels
            tableView.reloadData()
            
        case .isLoading: break
        case .loadingError(let message): break
        case .loadingMore: break
        }
    }
}

extension PayoutsHistoryVC {
    private enum Constants {
        static let tableViewBottomContentInset: CGFloat = 14
    }
}

extension PayoutsHistoryVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { payoutsHistoryVMs.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PayoutsTransactionCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
        let viewModel = payoutsHistoryVMs[indexPath.row]
        cell.configure(viewModel)
        return cell
    }
}

extension PayoutsHistoryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if indexPath.row == (payoutsHistoryVMs.count - 1), payoutsHistoryVMs.isNotEmpty {
            system?.send(.loadMore)
        }
    }
}
