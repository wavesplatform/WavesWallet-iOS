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
    
    private let system: System<TransactionCard.State, TransactionCard.Event> = TransactionCardSystem()

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
        
        let view = UIView()
        view.backgroundColor = .red
        return view
    }
    
    func modalHeaderHeight() -> CGFloat {
        return 54
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

//        let cell: TransactionCardGeneralCell = tableView.dequeueCell()
        let row = self[indexPath]

        switch row {
        case .general:
            let cell: TransactionCardGeneralCell = tableView.dequeueCell()

            return cell

        case .address:
            let cell: TransactionCardAddressCell = tableView.dequeueCell()

            return cell

        case .keyValue:
            let cell: TransactionCardKeyValueCell = tableView.dequeueCell()

            return cell

        case .keyBalance:
            let cell: TransactionCardKeyBalanceCell = tableView.dequeueCell()

            return cell

        case .status:
            let cell: TransactionCardStatusCell = tableView.dequeueCell()

            return cell

        case .massSentRecipient:
            let cell: TransactionCardMassSentRecipientCell = tableView.dequeueCell()

            return cell

        case .dashedLine:
            let cell: TransactionCardDashedLineCell = tableView.dequeueCell()

            return cell

        case .actions:
            let cell: TransactionCardActionsCell = tableView.dequeueCell()

            return cell

        case .description:
            let cell: TransactionCardDescriptionCell = tableView.dequeueCell()

            return cell

        case .exchange:
            let cell: TransactionCardExchangeCell = tableView.dequeueCell()

            return cell

        case .assetDetail:
            let cell: TransactionCardAssetDetailCell = tableView.dequeueCell()

            return cell

        case .showAll:
            let cell: TransactionCardShowAllCell = tableView.dequeueCell()

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
