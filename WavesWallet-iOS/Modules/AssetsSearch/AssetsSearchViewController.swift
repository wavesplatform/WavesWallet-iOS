//
//  WidgetSettingsViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.07.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Extensions
import DomainLayer

private typealias Types = WidgetSettings

final class WidgetSettingsViewController: UIViewController, DataSourceProtocol {
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    var system: System<WidgetSettings.State, WidgetSettings.Event>!
    
    weak var delegate: WidgetSettingsModuleOutput?

    @IBOutlet var tableView: UITableView!
    
    var sections: [WidgetSettings.Section] = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.isNavigationBarHidden = false
        navigationItem.shadowImage = UIImage()
        
        navigationItem.title = "Market pulse"
//        navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationItem.backgroundImage = UIColor.basic50.image
//        navigationController?.navigationBar.barTintColor = UIColor.basic50
//        setupTopBarLine()
        self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 12, right: 0)
        
        self.tableView.isEditing = true
        
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
    }
}

// MARK: Private

extension WidgetSettingsViewController {
    
    private func update(state: Types.State.Core) {
        
    }
    
    private func update(state: Types.State.UI) {
        
        switch state.action {
        case .update:
            
            self.sections = state.sections
            tableView.reloadData()
            
//        case .error(let error):
//            showNetworkErrorSnack(error: error)
            
        default:
            break
        }
    }
}

// MARK: UITableViewDataSource

extension WidgetSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self[indexPath]
        
        switch row {
        case .asset(let model):
            let cell: WidgetSettingsAssetCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.update(with: model)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        fileprivate let cardHeaderView: TransactionCardHeaderView = TransactionCardHeaderView.loadView() as! TransactionCardHeaderView
        let headerView: WidgetSettingsHeaderView = tableView.dequeueAndRegisterHeaderFooter()
        
        return headerView
    }
}

// MARK: UITableViewDelegate

extension WidgetSettingsViewController: UITableViewDelegate {
    
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
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        let row = self[indexPath]
        
        switch row {
        case .asset(let model) where model.isLock == true:
            return .none
            
        default:
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
//        if proposedDestinationIndexPath.section == sections.firstIndex(where: {$0.kind == .top}) {
//            if let favSectionIndex = sections.firstIndex(where: {$0.kind == .favorities}) {
//                return IndexPath(row: 0, section: favSectionIndex)
//            }
//        }
//        else if isEmptySection(at: proposedDestinationIndexPath) {
//            return IndexPath(row: 0, section: proposedDestinationIndexPath.section)
//        }
        return proposedDestinationIndexPath
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
//        let row = sections[indexPath.section].items[indexPath.row]
        return true
    }
}

