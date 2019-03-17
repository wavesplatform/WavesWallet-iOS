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

protocol TransactionCardViewControllerDelegate: AnyObject {
    func transactionCardAddContact(address: String)
    func transactionCardEditContact(contact: DomainLayer.DTO.Contact)

//    func transactionCardSendAgain(
}

protocol TransactionCardViewControllerInput: AnyObject {

    func addedContact(address: String, contact: DomainLayer.DTO.Contact)
    func editedContact(address: String, contact: DomainLayer.DTO.Contact)
    func deleteContact(address: String, contact: DomainLayer.DTO.Contact)
}

final class TransactionCardViewController: ModalScrollViewController, DataSourceProtocol {

    @IBOutlet var tableView: UITableView!
    
    override var scrollView: UIScrollView {
        return tableView!
    }
    
    private var rootView: TransactionCardView {
        return view as! TransactionCardView
    }

    private let disposeBag: DisposeBag = DisposeBag()

    var system: System<TransactionCard.State, TransactionCard.Event>!

    var sections: [TransactionCard.Section] = .init()

    weak var delegate: TransactionCardViewControllerDelegate?

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

        var inset: CGFloat = 0

        // TODO: presentedViewController == SLideVC

        if let vc = presentationController?.presentingViewController, vc.children.count > 1 {
            inset = vc.children[1].children.first?.children.first?.layoutInsets.top ?? 0
        }

        return size.height
//            - inset
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}

// MARK: Private

extension TransactionCardViewController {

    private func update(state: Types.State.UI) {

        switch state.action {
        case .update:
            self.sections = state.sections
            tableView.reloadData()

        case .insertRows(let rows, let insertIndexPaths, let deleteIndexPaths):
            
            self.sections = state.sections

            DispatchQueue.main.async {
                //TODO: Insert
                UIView.transition(with: self.tableView, duration: 0.24, options: .transitionCrossDissolve, animations: {
                    self.tableView.reloadData()
                }, completion: { (_) in

                })

            }

        default:
            break
        }

    }

    private func updateContact(address: String, contact: DomainLayer.DTO.Contact?, isAdd: Bool) {

        if isAdd {
            self.delegate?.transactionCardAddContact(address: address)
        } else {
            if let contact = contact {
                self.delegate?.transactionCardEditContact(contact: contact)
            }
        }
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


// MARK: TransactionCardViewControllerInput

extension TransactionCardViewController: TransactionCardViewControllerInput {

    func deleteContact(address: String, contact: DomainLayer.DTO.Contact) {
        self.system?.send(.deleteContact(contact: contact))
    }

    func addedContact(address: String, contact: DomainLayer.DTO.Contact) {
        self.system?.send(.addContact(contact: contact))
    }

    func editedContact(address: String, contact: DomainLayer.DTO.Contact) {
        self.system?.send(.editContact(contact: contact))
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
            cell.tapAddressBookButton = { [weak self] (isAdd) in
                self?.updateContact(address: model.contactDetail.address,
                                    contact: model.contact,
                                    isAdd: isAdd)
            }

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
            cell.tapAddressBookButton = { [weak self] (isAdd) in
                self?.updateContact(address: model.contactDetail.address,
                                    contact: model.contact,
                                    isAdd: isAdd)
            }

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

            cell.didTapButtonShowAll = { [weak self] in
                self?.system?.send(.showAllRecipients)
            }

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
