//
//  TransactionCardViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 04/03/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

private typealias Types = TransactionCard

final class TransactionCardViewController: ModalScrollViewController, DataSourceProtocol {

    @IBOutlet var tableView: UITableView!
    
    override var scrollView: UIScrollView {
        return tableView!
    }
    
    private var rootView: TransactionCardView {
        return view as! TransactionCardView
    }
    
    var system: System<TransactionCard.State, TransactionCard.Event>!

    private let disposeBag: DisposeBag = DisposeBag()

    var sections: [TransactionCard.Section] = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.delegate = self


        system
            .start()            
            .drive(onNext: { [weak self] (state) in
                self?.update(state: state.ui)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: ModalScrollViewContext
    override func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        return size.height * 0.85
    }
}

// MARK: Private

extension TransactionCardViewController {

    private func update(state: Types.State.UI) {
        self.sections = state.sections
        tableView.reloadData()
    }
}

// MARK: ModalRootViewDelegate

extension TransactionCardViewController: ModalRootViewDelegate {
    
    func modalHeaderView() -> UIView {
        
        let view = TransactionCardHeaderView.loadView()

        return view
    }
    
    func modalHeaderHeight() -> CGFloat {
        return 14
    }
}

// MARK: UITableViewDataSource

extension TransactionCardViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = self[indexPath]

        switch row {
        case .general(let model):
            let cell: TransactionCardGeneralCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .address(let model):
            let cell: TransactionCardAddressCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .keyValue(let model):
            let cell: TransactionCardKeyValueCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .keyBalance(let model):
            let cell: TransactionCardKeyBalanceCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .status(let model):
            let cell: TransactionCardStatusCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .massSentRecipient(let model):
            let cell: TransactionCardMassSentRecipientCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .dashedLine(let model):
            let cell: TransactionCardDashedLineCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .actions(let model):
            let cell: TransactionCardActionsCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .description(let model):
            let cell: TransactionCardDescriptionCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .exchange(let model):
            let cell: TransactionCardExchangeCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .assetDetail(let model):
            let cell: TransactionCardAssetDetailCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .showAll(let model):
            let cell: TransactionCardShowAllCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .asset(let model):
            let cell: TransactionCardAssetCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .sponsorshipDetail(let model):
            let cell: TransactionCardSponsorshipDetailCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell
        }
    }
}

// MARK: UITableViewDelegate

extension TransactionCardViewController: UITableViewDelegate {

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
