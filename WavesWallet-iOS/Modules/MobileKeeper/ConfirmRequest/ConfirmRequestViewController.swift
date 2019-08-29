//
//  ConfirmRequestViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Extensions
import DomainLayer

private typealias Types = ConfirmRequest

final class ConfirmRequestViewController: UIViewController, DataSourceProtocol {
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    var system: System<ConfirmRequest.State, ConfirmRequest.Event>!
    
    weak var moduleOutput: ConfirmRequestModuleOutput?
    
    @IBOutlet var tableView: UITableView!
    
    var sections: [ConfirmRequest.Section] = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.shadowImage = UIImage()
//        navigationItem.title = Localizable.Waves.Widgetsettings.Navigation.title
//        navigationItem.backgroundImage = UIColor.basic50.image
//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.topbarClose.image.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(topbarClose))
//        self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 12, right: 0)
        
        setupBigNavigationBar()
        hideTopBarLine()
        
        system
            .start()
            .drive(onNext: { [weak self] (state) in
                guard let self = self else { return }
                self.update(state: state.core)
                self.update(state: state.ui)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        system.send(.viewDidAppear)
    }
}

// MARK: System

private extension ConfirmRequestViewController {
    
    private func update(state: Types.State.Core) {
        
    }
    
    private func update(state: Types.State.UI) {
        
        self.sections = state.sections        
        
        switch state.action {
        case .update:
            tableView.reloadData()
            
        default:
            break
        }
    }
}

// MARK: UITableViewDataSource

extension ConfirmRequestViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self[indexPath]
        
        switch row {
        case .transactionKind(let model):
            let cell: ConfirmRequestTransactionKindCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.update(with: model)
            return cell
            
        case .balance(let model):
            return UITableViewCell()
            let cell: ConfirmRequestBalanceCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.update(with: model)
            return cell
            
        case .feeAndTimestamp(let model):
            return UITableViewCell()
            let cell: ConfirmRequestFeeAndTimestampCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.update(with: model)
            return cell
            
        case .fromTo(let model):
            return UITableViewCell()
            let cell: ConfirmRequestFromToCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.update(with: model)
            return cell
            
        case .keyValue(let model):
            return UITableViewCell()
            let cell: ConfirmRequestKeyValueCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.update(with: model)
            return cell
            
        case .skeleton:
            return UITableViewCell()
            let cell: ConfirmRequestSkeletonCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.startAnimation()
            return cell
        }
    }
}

// MARK: UITableViewDelegate

extension ConfirmRequestViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.minValue
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.minValue
    }
}


