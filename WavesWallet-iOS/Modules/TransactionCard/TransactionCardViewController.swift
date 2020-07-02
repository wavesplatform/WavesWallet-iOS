//
//  TransactionCardViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 04/03/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import Foundation
import RxSwift
import UIKit
import UITools

private typealias Types = TransactionCard

private struct Constants {
    static let sizeArrowButton: CGSize = .init(width: 48, height: 48)
    static let rightPaddingArrowButton: CGFloat = 24
    static let bottomPaddingArrowButton: CGFloat = 28
    static let cardHeaderViewHeight: CGFloat = 20
    static let animationDurationReloadTable: TimeInterval = 0.24
    static let arrowButtonCornerRadius: Float = 24
}

protocol TransactionCardModuleOutput: AnyObject {
    func transactionCardAddContact(address: String)
    func transactionCardEditContact(contact: DomainLayer.DTO.Contact)

    func transactionCardResendTransaction(_ transaction: SmartTransaction)
    func transactionCardCancelLeasing(_ transaction: SmartTransaction)
    func transactionCardCanceledOrder(_ order: DomainLayer.DTO.Dex.MyOrder)
    func transactionCardViewOnExplorer(_ transaction: SmartTransaction)

    func transactionCardViewDismissCard()
}

protocol TransactionCardModuleInput: AnyObject {
    func addedContact(address: String, contact: DomainLayer.DTO.Contact)
    func editedContact(address: String, contact: DomainLayer.DTO.Contact)
    func deleteContact(address: String, contact: DomainLayer.DTO.Contact)
}

final class TransactionCardScroll: ModalTableView {
    fileprivate var arrowButton: UIButton = {
        let arrowButton = ArrowButton(type: .custom)
        arrowButton.translatesAutoresizingMaskIntoConstraints = true
        arrowButton.setBackgroundImage(UIColor.basic50.image, for: .normal)
        arrowButton.setBackgroundImage(UIColor.basic200.image, for: .highlighted)
        arrowButton.cornerRadius = Constants.arrowButtonCornerRadius
        arrowButton.layer.masksToBounds = true
        arrowButton.setImage(Images.arrowdown24Black.image, for: .normal)
        return arrowButton
    }()

    var controllerLayoutInsets: UIEdgeInsets = .zero {
        didSet {
            layoutIfNeeded()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(arrowButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let screenHeight = frame.height - adjustedContentInset.top

        let contentHeight = contentSize.height

        var arrowFrame = arrowButton.frame
        arrowFrame.size = Constants.sizeArrowButton

        let xArrow = frame.width - arrowFrame.width - Constants.rightPaddingArrowButton
        if contentHeight > screenHeight {
            arrowFrame.origin = .init(x: xArrow,
                                      y: contentHeight)
        } else {
            let offset = screenHeight - contentHeight

            if offset > (arrowFrame.height + Constants.bottomPaddingArrowButton) {
                arrowFrame.origin = .init(x: xArrow,
                                          y: screenHeight - arrowFrame.height - Constants.bottomPaddingArrowButton)
            } else {
                arrowFrame.origin = .init(x: xArrow,
                                          y: contentHeight)
            }
        }

        arrowButton.frame = arrowFrame
    }

    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }
        return super.touchesShouldBegin(touches, with: event, in: view)
    }

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if arrowButton.frame.contains(point) {
            return arrowButton
        }

        return super.hitTest(point, with: event)
    }
}

private final class ArrowButton: UIButton {}

final class TransactionCardViewController: ModalScrollViewController, DataSourceProtocol {
    @IBOutlet private var tableView: TransactionCardScroll!

    override var scrollView: UIScrollView {
        tableView
    }

    private var rootView: TransactionCardView {
        view as! TransactionCardView
    }

    fileprivate var arrowButton: UIButton {
        tableView.arrowButton
    }

    fileprivate let cardHeaderView: TransactionCardHeaderView = TransactionCardHeaderView.loadView() as! TransactionCardHeaderView

    private let disposeBag: DisposeBag = DisposeBag()

    private var kind: Types.Kind?

    var system: System<TransactionCard.State, TransactionCard.Event>!

    var sections: [TransactionCard.Section] = .init()

    weak var delegate: TransactionCardModuleOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.delegate = self
        arrowButton.addTarget(self, action: #selector(handlerTapOnArrowButton(sender:)), for: .touchUpInside)

        navigationItem.isNavigationBarHidden = false
        navigationItem.shadowImage = nil

        system
            .start()
            .drive(onNext: { [weak self] state in
                guard let self = self else { return }
                self.update(state: state.core)
                self.update(state: state.ui)
            })
            .disposed(by: disposeBag)
    }

    // MARK: ModalScrollViewContext

    override func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        size.height
    }

    override func bottomScrollInset(for _: CGSize) -> CGFloat {
        Constants.sizeArrowButton.height + Constants.bottomPaddingArrowButton
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.controllerLayoutInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }

    private func layoutInsetsTop() -> CGFloat {
        let localInset = layoutInsets.top
        var inset: CGFloat = 0

        if let vc = presentingViewController {
            if let tabBarVc = vc as? UITabBarController,
                let selectedViewController = tabBarVc.selectedViewController as? UINavigationController,
                let topVc = selectedViewController.topViewController {
                inset = topVc.layoutInsets.top - localInset
            } else {
                inset = vc.layoutInsets.top - localInset
            }
        } else {
            inset = (presentingViewController?.layoutInsets.top ?? 0) - localInset
        }

        return inset
    }
}

// MARK: Private

extension TransactionCardViewController {
    @IBAction func handlerTapOnArrowButton(sender _: UIButton) {
        ImpactFeedbackGenerator.impactOccurred()
        delegate?.transactionCardViewDismissCard()
    }

    private func update(state: Types.State.Core) {
        kind = state.kind
    }

    private func update(state: Types.State.UI) {
        switch state.action {
        case .update:

            sections = state.sections
            tableView.reloadData()

        case .insertRows:

            sections = state.sections

            UIView.transition(with: tableView,
                              duration: Constants.animationDurationReloadTable,
                              options: .transitionCrossDissolve,
                              animations: {
                                  self.tableView.reloadData()
                              }, completion: { _ in

            })

        case .didCancelOrder:
            sections = state.sections
            tableView.reloadData()

            guard let order = kind?.order else { return }
            delegate?.transactionCardCanceledOrder(order)

        case let .error(error):
            showNetworkErrorSnack(error: error)

        default:
            break
        }
    }

    private func updateContact(address: String, contact: DomainLayer.DTO.Contact?, isAdd: Bool) {
        if isAdd {
            delegate?.transactionCardAddContact(address: address)
        } else {
            if let contact = contact {
                delegate?.transactionCardEditContact(contact: contact)
            }
        }
    }

    private func handlerTapActionButton(_ button: TransactionCardActionsCell.Model.Button) {
        switch button {
        case .cancelLeasing:
            guard let transaction = kind?.transaction else { return }
            delegate?.transactionCardCancelLeasing(transaction)

        case .sendAgain:
            guard let transaction = kind?.transaction else { return }
            delegate?.transactionCardResendTransaction(transaction)

        case .cancelOrder:
            system.send(.cancelOrder)

        case .copyAllData:

            guard let transaction = kind?.transaction else { return }
            DispatchQueue.main.async {
                UIPasteboard.general.string = transaction.allData
            }

        case .copyTxID:

            guard let transaction = kind?.transaction else { return }

            DispatchQueue.main.async {
                UIPasteboard.general.string = transaction.id
            }

        case .viewOnExplorer:
            guard let transaction = kind?.transaction else { return }
            delegate?.transactionCardViewOnExplorer(transaction)
        }
    }
}

// MARK: ModalRootViewDelegate

extension TransactionCardViewController: ModalRootViewDelegate {
    func modalHeaderView() -> UIView {
        return cardHeaderView
    }

    func modalHeaderHeight() -> CGFloat {
        return Constants.cardHeaderViewHeight
    }
}

// MARK: TransactionCardViewControllerInput

extension TransactionCardViewController: TransactionCardModuleInput {
    func deleteContact(address _: String, contact: DomainLayer.DTO.Contact) {
        system?.send(.deleteContact(contact: contact))
    }

    func addedContact(address _: String, contact: DomainLayer.DTO.Contact) {
        system?.send(.addContact(contact: contact))
    }

    func editedContact(address _: String, contact: DomainLayer.DTO.Contact) {
        system?.send(.editContact(contact: contact))
    }
}

// MARK: UITableViewDataSource

extension TransactionCardViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        sections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self[indexPath]

        switch row {
        case let .general(model):
            let cell: TransactionCardGeneralCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case let .address(model):
            let cell: TransactionCardAddressCell = tableView.dequeueCell()
            cell.update(with: model)
            cell.tapAddressBookButton = { [weak self] isAdd in
                guard let self = self else { return }

                self.updateContact(address: model.contactDetail.address, contact: model.contact, isAdd: isAdd)
            }

            return cell

        case let .keyValue(model):
            let cell: TransactionCardKeyValueCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case let .keyBalance(model):
            let cell: TransactionCardKeyBalanceCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case let .status(model):
            let cell: TransactionCardStatusCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case let .massSentRecipient(model):
            let cell: TransactionCardMassSentRecipientCell = tableView.dequeueCell()
            cell.update(with: model)
            cell.tapAddressBookButton = { [weak self] isAdd in
                guard let self = self else { return }
                self.updateContact(address: model.contactDetail.address,
                                   contact: model.contact,
                                   isAdd: isAdd)
            }

            return cell

        case let .dashedLine(model):
            let cell: TransactionCardDashedLineCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case let .actions(model):
            let cell: TransactionCardActionsCell = tableView.dequeueCell()
            cell.update(with: model)
            cell.tapOnButton = { [weak self] button in
                guard let self = self else { return }
                self.handlerTapActionButton(button)
            }

            return cell

        case let .description(model):
            let cell: TransactionCardDescriptionCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case let .exchange(model):
            let cell: TransactionCardExchangeCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case let .assetDetail(model):
            let cell: TransactionCardAssetDetailCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case let .showAll(model):
            let cell: TransactionCardShowAllCell = tableView.dequeueCell()
            cell.update(with: model)

            cell.didTapButtonShowAll = { [weak self] in
                guard let self = self else { return }
                self.system?.send(.showAllRecipients)
            }

            return cell

        case let .asset(model):
            let cell: TransactionCardAssetCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case let .sponsorshipDetail(model):
            let cell: TransactionCardSponsorshipDetailCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case let .order(model):

            let cell: TransactionCardOrderCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case let .keyLoading(model):
            let cell: TransactionCardKeyLoadingCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case let .invokeScript(model):
            let cell: TransactionCardInvokeScriptCell = tableView.dequeueCell()
            cell.update(with: model)
            return cell

        case let .orderFilled(model):
            let cell: TransactionCardOrderFilledCell = tableView.dequeueCell()
            cell.update(with: model)
            return cell

        case let .exchangeFee(model):
            let cell: TransactionCardExchangeFeeCell = tableView.dequeueCell()
            cell.update(with: model)
            return cell
        }
    }
}

// MARK: UITableViewDelegate

extension TransactionCardViewController: UITableViewDelegate {
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

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)

        let yOffset = scrollView.contentOffset.y + scrollView.contentInset.top

        if yOffset > scrollView.contentInset.top {
            cardHeaderView.isHiddenSepatator = false
        } else {
            cardHeaderView.isHiddenSepatator = true
        }
    }
}
