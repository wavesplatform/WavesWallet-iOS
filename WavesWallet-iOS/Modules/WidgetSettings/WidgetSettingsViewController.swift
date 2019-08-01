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

private struct Constants {
    
}

private typealias Types = WidgetSettings

final class WidgetSettingsViewController: UIViewController, DataSourceProtocol {
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    var system: System<WidgetSettings.State, WidgetSettings.Event>!
    
    weak var moduleOutput: WidgetSettingsModuleOutput?

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var intervalButton: UIButton!
    @IBOutlet var addTokenButton: UIButton!
    @IBOutlet var styleButton: UIButton!
    
    var sections: [WidgetSettings.Section] = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.shadowImage = UIImage()
        //TODO: Localization
        navigationItem.title = "Market pulse"
        navigationItem.backgroundImage = UIColor.basic50.image
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
    
    @IBAction private func handlerTouchForIntervalButton(_ sender: UIButton) {
        moduleOutput?.widgetSettingsChangeInterval(callback: { [weak self] (interval) in
            self?.system.send(.changeInterval(interval))
        })
    }
    
    @IBAction private func handlerTouchForAddTokenButton(_ sender: UIButton) {
        moduleOutput?.widgetSettingsAddAsset(callback: { [weak self] (asset) in
            self?.system.send(.addAsset(asset))
        })
    }
    
    @IBAction private func handlerTouchForStyleButton(_ sender: UIButton) {
        moduleOutput?.widgetSettingsChangeStyle(callback: { [weak self] (style) in
            self?.system.send(.changeStyle(style))
        })
    }
}

// MARK: Private

private extension WidgetSettingsViewController {
    
    private func update(state: Types.State.Core) {
        
    }
    
    private func update(state: Types.State.UI) {
        
        self.sections = state.sections
        
        switch state.action {
        case .update:
            tableView.reloadData()
        
        case .deleteRow(let indexPath):
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if let headerView = tableView.headerView(forSection: 0) as? WidgetSettingsHeaderView {
                let section = state.sections[0]
                headerView.update(with: .init(amountMax: section.limitAssets, amount: section.rows.count))
            }
            
            tableView.endUpdates()
            
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
        
        let section = self[section]
    
        let headerView: WidgetSettingsHeaderView = tableView.dequeueAndRegisterHeaderFooter()
        headerView.update(with: .init(amountMax: section.limitAssets, amount: section.rows.count))
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
        system.send(.moveRow(from: sourceIndexPath, to: destinationIndexPath))
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //TODO: Localization
        let editAction = UITableViewRowAction.init(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            self?.system.send(.rowDelete(indexPath: indexPath))
        }

        return [editAction]
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath
    }
    
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

