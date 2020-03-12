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
            tableView.registerCell(type: PayoutsTransactionCell.self)
            
            tableView.contentInset.bottom = Constants.tableViewBottomContentInset
            tableView.separatorStyle = .none
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    private func bindUI(_ state: PayoutsHistoryState.UI) {
        switch state {
        case .dataLoadded(let viewModels):
            self.payoutsHistoryVMs = viewModels
            tableView.reloadData()
        case .showLoadingIndicator:
            break
        case .hideLoadingIndicator:
            break
        case .loadingError(let message):
            break
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
        
        let currency = DomainLayer.DTO.Balance.Currency(title: "Bitcoin", ticker: "USDN")
        let money = Money(8, 8)
        let balance = DomainLayer.DTO.Balance(currency: currency, money: money)
        let transactionValue = BalanceLabel.Model(balance: balance, sign: .plus, style: .small)
        let viewModel = PayoutsHistoryState.UI.PayoutTransactionVM(title: "Profit",
                                                                   details: "Details profit",
                                                                   transactionValue: transactionValue,
                                                                   dateText: "18 june")
        cell.configure(viewModel)
        return cell
    }
}

extension PayoutsHistoryVC: UITableViewDelegate {
    
}
