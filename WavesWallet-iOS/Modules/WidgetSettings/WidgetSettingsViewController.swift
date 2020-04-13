//
//  WidgetSettingsViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 28.07.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift
import UIKit

private struct Constants {
    static let headerHeight: CGFloat = 42
}

private typealias Types = WidgetSettings

final class WidgetSettingsViewController: UIViewController, DataSourceProtocol {
    private let disposeBag: DisposeBag = DisposeBag()

    var system: System<WidgetSettings.State, WidgetSettings.Event>!

    weak var moduleOutput: WidgetSettingsModuleOutput?

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var intervalButton: UIButton!
    @IBOutlet private var addTokenButton: UIButton!
    @IBOutlet private var styleButton: UIButton!

    var sections: [WidgetSettings.Section] = .init()

    private var interval: DomainLayer.DTO.Widget.Interval?
    private var style: DomainLayer.DTO.Widget.Style?
    private var assets: [DomainLayer.DTO.Asset] = []

    private var minCountAssets: Int = 0
    private var maxCountAssets: Int = 0
    fileprivate var snackError: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.shadowImage = UIImage()
        navigationItem.title = Localizable.Waves.Widgetsettings.Navigation.title
        navigationItem.backgroundImage = UIColor.basic50.image
        navigationItem
            .rightBarButtonItem = UIBarButtonItem(image: Images.check18Success400.image.withRenderingMode(.alwaysOriginal),
                                                  style: .plain, target: self, action: #selector(topbarClose))
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)

        system
            .start()
            .drive(onNext: { [weak self] state in
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

    @IBAction private func handlerTouchForIntervalButton(_: UIButton) {
        moduleOutput?.widgetSettingsChangeInterval(interval, callback: { [weak self] interval in
            self?.system.send(.changeInterval(interval))
        })
    }

    @IBAction private func handlerTouchForAddTokenButton(_: UIButton) {
        moduleOutput?
            .widgetSettingsSyncAssets(assets, minCountAssets: minCountAssets, maxCountAssets: maxCountAssets,
                                      callback: { [weak self] assets in
                                          self?.system.send(.syncAssets(assets))
        })
    }

    @IBAction private func handlerTouchForStyleButton(_: UIButton) {
        moduleOutput?.widgetSettingsChangeStyle(style, callback: { [weak self] style in
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
        interval = state.interval
        style = state.style
        assets = state.assets
        maxCountAssets = state.maxCountAssets
        minCountAssets = state.minCountAssets

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

        intervalButton.setTitle(title, for: .normal)
        styleButton.setTitle(state.style.title, for: .normal)
        addTokenButton.setTitle(Localizable.Waves.Widgetsettings.Button.addToken, for: .normal)
    }

    private func update(state: Types.State.UI) {
        sections = state.sections
        tableView.isEditing = state.isEditing

        if let snackError = self.snackError {
            hideSnack(key: snackError)
        }

        switch state.action {
        case .update:
            tableView.reloadData()

        case let .deleteRow(indexPath):

            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)

            if let headerView = tableView.headerView(forSection: 0) as? WidgetSettingsHeaderView {
                let section = state.sections[0]
                let rows = section.rows.filter { $0.asset != nil }
                headerView.update(with: .init(amountMax: section.limitAssets, amount: rows.count))
            }

            tableView.endUpdates()

        case let .error(error):
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

        case let .message(message):
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

    private func showErrorSnack(_ message: String) -> String {
        return showErrorSnack(title: message, didTap: { [weak self] in
            self?.system.send(.refresh)
        })
    }

    private func showErrorNotFoundSnack() -> String {
        return showErrorNotFoundSnack { [weak self] in
            self?.system.send(.refresh)
        }
    }
}

// MARK: UITableViewDataSource

extension WidgetSettingsViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return sections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self[indexPath]

        switch row {
        case let .asset(model):
            let cell: WidgetSettingsAssetCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.update(with: model)
            cell.deleteAction = { [weak self] cell in

                guard let self = self else { return }

                if let indexPath = self.tableView.indexPath(for: cell) {
                    self.system.send(.rowDelete(indexPath: indexPath))
                }
            }
            return cell

        case .skeleton:
            let cell: WidgetSettingsSkeletonCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.startAnimation()
            return cell
        }
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
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
    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, estimatedHeightForFooterInSection _: Int) -> CGFloat {
        return CGFloat.minValue
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return CGFloat.minValue
    }

    func tableView(_: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        system.send(.moveRow(from: sourceIndexPath, to: destinationIndexPath))
    }

    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_: UITableView, shouldIndentWhileEditingRowAt _: IndexPath) -> Bool {
        return false
    }

    func tableView(
        _: UITableView,
        targetIndexPathForMoveFromRowAt _: IndexPath,
        toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath
    }

    func tableView(_: UITableView, canMoveRowAt _: IndexPath) -> Bool {
        return true
    }
}
