//
//  PaymentHistoryVC.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 04.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit

class PayoutsHistoryVC: UIViewController {
    
    var system: System<PayoutsHistoryState, PayoutsHistoryEvents>?
    
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    private func initialSetup() {
        title = "Payouts History"
        
        do {
            tableView.registerCell(type: PayoutsTransactionCell.self)
            
            tableView.contentInset.bottom = Constants.tableViewBottomContentInset
            tableView.separatorStyle = .none
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
}

extension PayoutsHistoryVC {
    private enum Constants {
        static let tableViewBottomContentInset: CGFloat = 14
    }
}

extension PayoutsHistoryVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
    
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
