//
//  NewTransactionHistoryContentView.swift
//  WavesWallet-iOS
//
//  Created by Mac on 27/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let titleEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
}

protocol TransactionHistoryContentViewDelegate: class {
    
    func contentViewDidPressAccount(view: NewTransactionHistoryContentView)
    func contentViewDidPressButton(view: NewTransactionHistoryContentView)
    
}

class NewTransactionHistoryContentView: UIView {

    weak var delegate: TransactionHistoryContentViewDelegate?
    
    @IBOutlet weak var copyTXButton: UIButton!
    @IBOutlet weak var copyAllDataButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!

    private(set) var display: TransactionHistoryTypes.State.DisplayState?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupTableView()
        setupButtons()
    }

    // MARK: - Setups
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupButtons() {
        copyTXButton.titleEdgeInsets = Constants.titleEdgeInsets
        copyAllDataButton.titleEdgeInsets = Constants.titleEdgeInsets
    }
    
    // MARK: - Actions
    
    @IBAction func copyTXTapped(_ sender: Any) {
        
    }
    
    @IBAction func copyAllDataTapped(_ sender: Any) {
        
    }

}

// MARK: - Content

extension NewTransactionHistoryContentView {
    
    func setup(with display: TransactionHistoryTypes.State.DisplayState) {
        
        self.display = display
        tableView.reloadData()
        
    }
    
}

extension NewTransactionHistoryContentView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return display?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return display?.sections[section].items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = display!.sections[indexPath.section].items[indexPath.item]
        
        switch item {
        case .recipient(let model):
            
            let cell: TransactionHistoryRecipientCell = tableView.dequeueAndRegisterCell()
            cell.update(with: model)
            return cell
            
        case .comment(let model):
            
            let cell: TransactionHistoryCommentCell = tableView.dequeueAndRegisterCell()
            cell.update(with: model)
            return cell
            
        case .keyValue(let model):
            
            let cell: TransactionHistoryKeyValueCell = tableView.dequeueAndRegisterCell()
            cell.update(with: model)
            return cell
            
        case .keysValues(let model):
            
            let cell: TransactionHistoryKeysValuesCell = tableView.dequeueAndRegisterCell()
            cell.update(with: model)
            return cell
            
        case .resendButton(let model):
            
            let cell: TransactionHistoryButtonCell = tableView.dequeueAndRegisterCell()
            cell.update(with: model)
            cell.delegate = self
            return cell
         
        case .status(let model):
            
            let cell: TransactionHistoryStatusCell = tableView.dequeueAndRegisterCell()
            cell.update(with: model)
            return cell
            
        case .general(let model):
            
            let cell: TransactionHistoryGeneralCell = tableView.dequeueAndRegisterCell()
            cell.update(with: model)
            return cell
            
        }
        
    }
    
}

extension NewTransactionHistoryContentView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
         let item = display!.sections[indexPath.section].items[indexPath.item]
        
        switch item {
        case .recipient(let model):
            return TransactionHistoryRecipientCell.viewHeight(model: model, width: tableView.bounds.width) 
        case .comment(let model):
            return TransactionHistoryCommentCell.viewHeight(model: model, width: tableView.bounds.width)
        case .keyValue(_):
            return TransactionHistoryKeyValueCell.cellHeight()
        case .keysValues(_):
            return TransactionHistoryKeysValuesCell.cellHeight()
        case .resendButton(_):
            return TransactionHistoryButtonCell.cellHeight()
        case .status(_):
            return TransactionHistoryStatusCell.cellHeight()
        case .general(let model):
            return TransactionHistoryGeneralCell.viewHeight(model: model, width: tableView.bounds.width)
        }
        
    }

    
}

extension NewTransactionHistoryContentView: TransactionHistoryButtonCellDelegate {
    
    func transactionButtonCellDidPress(cell: TransactionHistoryButtonCell) {
        
        delegate?.contentViewDidPressButton(view: self)
        
    }
    
}

extension NewTransactionHistoryContentView: TransactionHistoryRecipientCellDelegate {
    
    func recipientCellDidPressContact(cell: TransactionHistoryRecipientCell) {
        
        delegate?.contentViewDidPressAccount(view: self)
        
    }

}


