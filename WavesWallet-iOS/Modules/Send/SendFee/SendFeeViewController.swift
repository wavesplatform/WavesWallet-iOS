//
//  SendFeeViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/31/19.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Extensions
import RxCocoa
import RxFeedback
import RxSwift
import UIKit
import UITools

private enum Constants {
    static let contentHeight: CGFloat = 288
    static let headerHeight: CGFloat = 74
}

final class SendFeeViewController: ModalScrollViewController {
    weak var delegate: SendFeeModuleOutput!
    var presenter: SendFeePresenterProtocol!

    @IBOutlet private weak var tableView: UITableView!

    private var modalRootView: ModalRootView {
        return view as! ModalRootView
    }

    private var sections: [SendFee.ViewModel.Section] = []
    private let sendEvent: PublishRelay<SendFee.Event> = PublishRelay<SendFee.Event>()

    override func viewDidLoad() {
        super.viewDidLoad()
        modalRootView.delegate = self
        setupFeedBack()
    }

    override var scrollView: UIScrollView {
        return self.tableView
    }

    override func visibleScrollViewHeight(for _: CGSize) -> CGFloat {
        return Constants.contentHeight + Constants.headerHeight
    }
}

// MARK: - FeedBack

private extension SendFeeViewController {
    func setupFeedBack() {
        let feedback = bind(self) { owner, state -> Bindings<SendFee.Event> in
            Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        presenter.system(feedbacks: [feedback])
    }

    func events() -> [Signal<SendFee.Event>] {
        return [sendEvent.asSignal()]
    }

    func subscriptions(state: Driver<SendFee.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in

                guard let self = self else { return }
                switch state.action {
                case .none:
                    return

                case .update:
                    self.sections = state.sections
                    self.tableView.reloadData()

                case let .handleError(error):
                    self.showNetworkErrorSnack(error: error)
                }
            })

        return [subscriptionSections]
    }
}

// MARK: - UITableViewDelegate

extension SendFeeViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = sections[indexPath.section].items[indexPath.row]

        switch row {
        case let .asset(asset):
            if !asset.isActive {
                return
            }
            delegate.sendFeeModuleDidSelectAssetFee(asset.assetBalance, fee: asset.fee)
        default:
            break
        }
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = sections[indexPath.section].items[indexPath.row]

        switch row {
        case .indicator:
            return Constants.contentHeight - Constants.headerHeight

        case .asset:
            return SendFeeTableViewCell.viewHeight()
        }
    }
}

// MARK: - UITableViewDataSource

extension SendFeeViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return sections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].items[indexPath.row]

        switch row {
        case .indicator:
            let cell = tableView.dequeueCell() as SendFeeIndicatorCell
            return cell

        case let .asset(asset):
            let cell = tableView.dequeueCell() as SendFeeTableViewCell
            cell.update(with: asset)
            return cell
        }
    }
}

// MARK: - UITableViewDataSource

extension SendFeeViewController: ModalRootViewDelegate {
    func modalHeaderView() -> UIView {
        let sendFeeHeaderView: SendFeeHeaderView = SendFeeHeaderView.loadView() as! SendFeeHeaderView
        return sendFeeHeaderView
    }

    func modalHeaderHeight() -> CGFloat {
        return Constants.headerHeight
    }
}
