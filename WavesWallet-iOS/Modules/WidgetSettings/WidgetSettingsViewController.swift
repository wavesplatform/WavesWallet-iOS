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
    static let headerHeight: CGFloat = 42
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
    
    private var interval: DomainLayer.DTO.Widget.Interval?
    private var style: DomainLayer.DTO.Widget.Style?
    private var assets: [DomainLayer.DTO.Asset] = []
    
    private var minCountAssets: Int = 0
    private var maxCountAssets: Int = 0
    fileprivate var snackError: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.shadowImage = UIImage()        
        navigationItem.title = Localizable.Waves.Widgetsettings.Navigation.title
        navigationItem.backgroundImage = UIColor.basic50.image
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.topbarClose.image.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(topbarClose))
        self.tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 12, right: 0)
                        
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
    
    @IBAction private func handlerTouchForIntervalButton(_ sender: UIButton) {
        moduleOutput?.widgetSettingsChangeInterval(interval, callback: { [weak self] (interval) in
            self?.system.send(.changeInterval(interval))
        })
    }
    
    @IBAction private func handlerTouchForAddTokenButton(_ sender: UIButton) {
        
        self.moduleOutput?.widgetSettingsSyncAssets(self.assets, minCountAssets: minCountAssets, maxCountAssets: maxCountAssets, callback: { [weak self] (assets) in
            self?.system.send(.syncAssets(assets))
        })
    }
    
    @IBAction private func handlerTouchForStyleButton(_ sender: UIButton) {
        moduleOutput?.widgetSettingsChangeStyle(style, callback: { [weak self] (style) in
            self?.system.send(.changeStyle(style))
        })
    }
    
    @objc func topbarClose() {
        moduleOutput?.widgetSettingsClose()
    }
}

// MARK: System

private extension WidgetSettingsViewController {
    
    private func update(state: Types.State.Core) {
        self.interval = state.interval
        self.style = state.style
        self.assets = state.assets
        self.maxCountAssets = state.maxCountAssets
        self.minCountAssets = state.minCountAssets
        
        let title = { () -> String in
           
            switch state.interval {
            case .m1:
                return Localizable.Waves.Widgetsettings.Changeinterval.Button.m1
            case .m5:
                return Localizable.Waves.Widgetsettings.Changeinterval.Button.m5
            case .m10:
                return Localizable.Waves.Widgetsettings.Changeinterval.Button.m10
            case .manually:
                return Localizable.Waves.Widgetsettings.Changeinterval.Button.manually
            }
        }()
        
        self.intervalButton.setTitle(title, for: .normal)
        self.styleButton.setTitle(state.style.title, for: .normal)
    }
    
    private func update(state: Types.State.UI) {
        
        self.sections = state.sections
        self.tableView.isEditing = state.isEditing
        
        if let snackError = self.snackError {
            hideSnack(key: snackError)
        }
        
        switch state.action {
        case .update:
            tableView.reloadData()
        
        case .deleteRow(let indexPath):
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if let headerView = tableView.headerView(forSection: 0) as? WidgetSettingsHeaderView {
                let section = state.sections[0]
                let rows = section.rows.filter { $0.asset != nil }
                headerView.update(with: .init(amountMax: section.limitAssets, amount: rows.count))
            }
            
            tableView.endUpdates()
        
        case .error(let error):
            showErrorView(with: error)
            
        default:
            break
        }
    }
    
    private func showErrorView(with error: DisplayError) {
        
        switch error {
        case .globalError:
            snackError = showWithoutInternetSnack()
            
        case .internetNotWorking:
            snackError = showWithoutInternetSnack()
            
        case .message(let message):
            snackError = showErrorSnack(message)
            
        default:
            snackError = showErrorNotFoundSnack()
            
        }
    }
    
    private func showWithoutInternetSnack() -> String {
        return showWithoutInternetSnack { [weak self] in
            self?.system.send(.refresh)
        }
    }
    
    private func showErrorSnack(_ message: (String)) -> String {
        return showErrorSnack(title: message, didTap: { [weak self] in
            self?.system.send(.refresh)
        })
    }
    
    private func showErrorNotFoundSnack() -> String {
        return showErrorNotFoundSnack() { [weak self] in
            self?.system.send(.refresh)
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
            
        case .skeleton:
            let cell: WidgetSettingsSkeletonCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.startAnimation()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let section = self[section]
    
        let headerView: WidgetSettingsHeaderView = tableView.dequeueAndRegisterHeaderFooter()
        let rows = section.rows.filter { $0.asset != nil }
        headerView.update(with: .init(amountMax: section.limitAssets, amount: rows.count))
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
            
        case .skeleton:
            return .none
            
        default:
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let title = Localizable.Waves.Widgetsettings.Tableview.Editmode.delete
        let editAction = UITableViewRowAction.init(style: .destructive, title: title) { [weak self] (action, indexPath) in
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

