//
//  ConfirmRequestViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift
import UIKit
import UITools

private typealias Types = ConfirmRequest

final class ConfirmRequestViewController: UIViewController, DataSourceProtocol {
    private let disposeBag: DisposeBag = DisposeBag()

    var system: System<ConfirmRequest.State, ConfirmRequest.Event>!

    weak var moduleOutput: ConfirmRequestModuleOutput?

    @IBOutlet private var tableView: UITableView!

    var sections: [ConfirmRequest.Section] = .init()

    private var complitingRequest: ConfirmRequest.DTO.ComplitingRequest?
    private var prepareRequest: DomainLayer.DTO.MobileKeeper.PrepareRequest?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizable.Waves.Keeper.Label.confirmRequest

        setupBigNavigationBar()
        removeTopBarLine()
        createBackButton()

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
}

// MARK: System

private extension ConfirmRequestViewController {
    private func update(state: Types.State.Core) {
        complitingRequest = state.complitingRequest
        prepareRequest = state.prepareRequest
    }

    private func update(state: Types.State.UI) {
        sections = state.sections

        switch state.action {
        case .update:
            tableView.reloadData()

        case .closeRequest:

            if let prepareRequest = prepareRequest {
                moduleOutput?.confirmRequestDidTapClose(prepareRequest)
            }
        default:
            break
        }
    }
}

// MARK: UITableViewDataSource

extension ConfirmRequestViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return sections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self[indexPath]

        switch row {
        case let .transactionKind(model):
            let cell: ConfirmRequestTransactionKindCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.update(with: model)
            return cell

        case let .balance(model):

            let cell: ConfirmRequestBalanceCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.update(with: model)
            return cell

        case let .feeAndTimestamp(model):

            let cell: ConfirmRequestFeeAndTimestampCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.update(with: model)
            return cell

        case let .fromTo(model):

            let cell: ConfirmRequestFromToCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.update(with: model)
            return cell

        case let .keyValue(model):
            let cell: ConfirmRequestKeyValueCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.update(with: model)
            return cell

        case .skeleton:

            let cell: ConfirmRequestSkeletonCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)
            cell.startAnimation()
            return cell

        case .buttons:

            let cell: ConfirmRequestButtonsCell = tableView.dequeueCellForIndexPath(indexPath: indexPath)

            cell.approveButtonDidTap = { [weak self] in

                guard let self = self else { return }
                guard let complitingRequest = self.complitingRequest else { return }

                self.moduleOutput?.confirmRequestDidTapApprove(complitingRequest)
            }

            cell.rejectButtonDidTap = { [weak self] in

                guard let self = self else { return }
                guard let complitingRequest = self.complitingRequest else { return }

                self.moduleOutput?.confirmRequestDidTapReject(complitingRequest)
            }

            return cell
        }
    }
}

// MARK: UITableViewDelegate

extension ConfirmRequestViewController: UITableViewDelegate {
    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_: UITableView, estimatedHeightForFooterInSection _: Int) -> CGFloat {
        CGFloat.leastNonzeroMagnitude
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        CGFloat.leastNonzeroMagnitude
    }
}
