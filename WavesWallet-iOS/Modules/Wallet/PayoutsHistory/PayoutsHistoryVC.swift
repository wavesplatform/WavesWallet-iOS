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
import WavesSDK

class PayoutsHistoryVC: UIViewController {
    
    private enum Constant {
        static let tableViewBottomContentInset: CGFloat = 14
        
        static let payoutsTransactionsSkeletonCellHeight: CGFloat = 68
    }
    
    var system: System<PayoutsHistoryState, PayoutsHistoryEvents>?
    
    @IBOutlet private weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    
    private var canLoadMore = false
    private var rowItems: [RowItem] = []
    
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
        
        navigationItem.title = Localizable.Waves.Payoutshistory.title
        navigationItem.barTintColor = .white
        
        setupTableView()
    }
    
    private func setupTableView() {
        refreshControl
            .rx
            .controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in self?.system?.send(.pullToRefresh) })
            .disposed(by: disposeBag)
        
        tableView.refreshControl = refreshControl
        tableView.registerCell(type: PayoutsTransactionCell.self)
        tableView.registerCell(type: PayoutsTransactionsSkeletonCell.self)
        
        tableView.contentInset.bottom = Constant.tableViewBottomContentInset
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func bindUI(_ state: PayoutsHistoryState.UI) {
        canLoadMore = state.canLoadMore
        
        refreshControl.endRefreshing()
        
        switch state.state {
        case .dataLoaded:
            let rowItems = state.viewModels.map { RowItem.payoutHistoryCell($0) }
            self.rowItems = rowItems
            
            tableView.reloadData()
        case .isLoading:
            let rowItems = [RowItem](repeating: .payoutsHistorySkeleton, count: 10)
            self.rowItems = rowItems
            
            tableView.reloadData()
        case .loadingError(let message):
            var keySnackBar: String = ""
            let didTap: () -> Void = { [weak self] in
                self?.system?.send(.performInitialLoading)
                self?.hideSnack(key: keySnackBar)
            }
            
            keySnackBar = showErrorSnack(title: message, didTap: didTap)
        case .loadingMore: break
        }
    }
}

extension PayoutsHistoryVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rowItems.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let rowItem = rowItems[safe: indexPath.row] {
            switch rowItem {
            case .payoutHistoryCell(let viewModel):
                let cell: PayoutsTransactionCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
                cell.update(with: viewModel)
                return cell
            case .payoutsHistorySkeleton:
                let cell: PayoutsTransactionsSkeletonCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
                return cell
            }
        } else {
            return UITableViewCell()
        }
    }
}

extension PayoutsHistoryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.cellForRow(at: indexPath) is PayoutsTransactionsSkeletonCell {
            return Constant.payoutsTransactionsSkeletonCellHeight
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        
        if let cell = cell as? PayoutsTransactionsSkeletonCell {
            cell.startAnimation()
        }
        if cell is PayoutsTransactionCell, rowItems.isNotEmpty, indexPath.row == rowItems.endIndex - 1, canLoadMore {
            system?.send(.loadMore)
        }
    }
}

extension PayoutsHistoryVC {
    enum RowItem {
        case payoutHistoryCell(PayoutsHistoryState.UI.PayoutTransactionVM)
        case payoutsHistorySkeleton
    }
}
