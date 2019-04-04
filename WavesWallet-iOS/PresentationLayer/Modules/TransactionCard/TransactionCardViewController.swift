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

    func transactionCardResendTransaction(_ transaction: DomainLayer.DTO.SmartTransaction)
    func transactionCardCancelLeasing(_ transaction: DomainLayer.DTO.SmartTransaction)
    func transactionCardCanceledOrder(_ order: DomainLayer.DTO.Dex.MyOrder)
    func transactionCardViewOnExplorer(_ transaction: DomainLayer.DTO.SmartTransaction)

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

        let screenHeight = self.frame.height - contentInset.top - controllerLayoutInsets.bottom
        let contentHeight = contentSize.height

        var arrowFrame = arrowButton.frame
        arrowFrame.size = Constants.sizeArrowButton

        let xArrow = self.frame.width - arrowFrame.width - Constants.rightPaddingArrowButton
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

final private class ArrowButton: UIButton { }

final class TransactionCardViewController: ModalScrollViewController, DataSourceProtocol {

    @IBOutlet var tableView: TransactionCardScroll!

    override var scrollView: UIScrollView {
        return tableView!
    }
    
    private var rootView: TransactionCardView {
        return view as! TransactionCardView
    }

    fileprivate var arrowButton: UIButton {
        return self.tableView.arrowButton
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

        navigationItem.isNavigationBarHidden = true
        navigationItem.shadowImage = nil

        system
            .start()
            .drive(onNext: { [weak self] (state) in
                guard let self = self else { return }
                self.update(state: state.core)
                self.update(state: state.ui)
            })
            .disposed(by: disposeBag)
    }

    // MARK: ModalScrollViewContext
    override func visibleScrollViewHeight(for size: CGSize) -> CGFloat {

        var inset: CGFloat = 0

        let localInset = self.layoutInsets.top

        //TODO: How fix it code?
        if let vc = presentingViewController as? SlideMenuProtocol {

            if let tabBarVc = vc.mainViewController as? UITabBarController,
                let selectedViewController = tabBarVc.selectedViewController as? UINavigationController,
                let topVc = selectedViewController.topViewController {

                inset = topVc.layoutInsets.top - localInset
            } else {
                inset = vc.mainViewController.layoutInsets.top - localInset
            }
        } else {
            inset = (presentingViewController?.layoutInsets.top ?? 0) - localInset
        }

        return size.height - inset
    }

    override func bottomScrollInset(for size: CGSize) -> CGFloat {
        return Constants.sizeArrowButton.height + Constants.bottomPaddingArrowButton
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.tableView.controllerLayoutInsets = self.layoutInsets
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: Private

extension TransactionCardViewController {

    @IBAction func handlerTapOnArrowButton(sender: UIButton) {
        ImpactFeedbackGenerator.impactOccurred()
        self.delegate?.transactionCardViewDismissCard()
    }

    private func update(state: Types.State.Core) {
        self.kind = state.kind
    }

    private func update(state: Types.State.UI) {

        switch state.action {
        case .update:

            self.sections = state.sections
            tableView.reloadData()

        case .insertRows:
            
            self.sections = state.sections

            UIView.transition(with: self.tableView,
                              duration: Constants.animationDurationReloadTable,
                              options: .transitionCrossDissolve,
                              animations: {
                self.tableView.reloadData()
            }, completion: { (_) in

            })

        case .didCancelOrder:
            self.sections = state.sections
            tableView.reloadData()

            guard let order = self.kind?.order else { return }
            self.delegate?.transactionCardCanceledOrder(order)

        case .error(let error):
            showNetworkErrorSnack(error: error)

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

    private func handlerTapActionButton(_ button: TransactionCardActionsCell.Model.Button) {

        switch button {
        case .cancelLeasing:
            guard let transaction = self.kind?.transaction else { return }
            self.delegate?.transactionCardCancelLeasing(transaction)

        case .sendAgain:
            guard let transaction = self.kind?.transaction else { return }
            self.delegate?.transactionCardResendTransaction(transaction)

        case .cancelOrder:
            self.system.send(.cancelOrder)
            
        case .copyAllData:

            guard let transaction = self.kind?.transaction else { return }
            DispatchQueue.main.async {
                UIPasteboard.general.string = transaction.allData
            }

        case .copyTxID:

            guard let transaction = self.kind?.transaction else { return }

            DispatchQueue.main.async {
                UIPasteboard.general.string = transaction.id
            }

        case .viewOnExplorer:
            guard let transaction = self.kind?.transaction else { return }
            self.delegate?.transactionCardViewOnExplorer(transaction)
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
            let cell:TransactionCardAddressCell = tableView.dequeueCell()
            cell.update(with: model)
            cell.tapAddressBookButton = { [weak self] (isAdd) in

                guard let self = self else { return }

                self.updateContact(address: model.contactDetail.address,
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

                guard let self = self else { return }
                self.updateContact(address: model.contactDetail.address,
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
            cell.tapOnButton = { [weak self] (button)  in
                guard let self = self else { return }
                self.handlerTapActionButton(button)
            }

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
                guard let self = self else { return }
                self.system?.send(.showAllRecipients)
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

        case .order(let model):

            let cell: TransactionCardOrderCell = tableView.dequeueCell()
            cell.update(with: model)

            return cell

        case .keyLoading(let model):
            let cell: TransactionCardKeyLoadingCell = tableView.dequeueCell()
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
