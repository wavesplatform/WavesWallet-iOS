//
//  AddressesKeysViewController.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25/10/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Extensions
import RxCocoa
import RxFeedback
import RxSwift
import UIKit
import UITools

final class AddressesKeysViewController: UIViewController {
    typealias Types = AddressesKeysTypes

    @IBOutlet private var tableView: UITableView!

    private var sections: [Types.ViewModel.Section] = []
    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()

    var presenter: AddressesKeysPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()
        setupBigNavigationBar()
        navigationItem.title = Localizable.Waves.Addresseskeys.Navigation.title
        navigationItem.barTintColor = .white

        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()

        setupSystem()
    }
}

// MARK: RxFeedback

private extension AddressesKeysViewController {
    func setupSystem() {
        let uiFeedback: AddressesKeysPresenterProtocol.Feedback = bind(self) { (owner, state) -> (Bindings<Types.Event>) in
            Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        let readyViewFeedback: AddressesKeysPresenterProtocol.Feedback = { [weak self] _ in
            guard let self = self else { return Signal.empty() }

            return self.rx.viewWillAppear.asObservable()
                .throttle(1, scheduler: MainScheduler.asyncInstance)
                .asSignal(onErrorSignalWith: Signal.empty())
                .map { _ in Types.Event.viewWillAppear }
        }

        let viewDidDisappearFeedback: AddressesKeysPresenterProtocol.Feedback = { [weak self] _ in
            guard let self = self else { return Signal.empty() }

            return self.rx.viewDidDisappear.asObservable()
                .throttle(1, scheduler: MainScheduler.asyncInstance)
                .asSignal(onErrorSignalWith: Signal.empty())
                .map { _ in Types.Event.viewDidDisappear }
        }

        presenter.system(feedbacks: [uiFeedback, readyViewFeedback, viewDidDisappearFeedback])
    }

    func events() -> [Signal<Types.Event>] {
        return [eventInput.asSignal(onErrorSignalWith: Signal.empty())]
    }

    func subscriptions(state: Driver<Types.State>) -> [Disposable] {
        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let self = self else { return }

            self.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }

    func updateView(with state: Types.DisplayState) {
        sections = state.sections
        if let action = state.action {
            switch action {
            case .update:

                tableView.reloadData()
            case .none:
                break
            }
        }
    }
}

// MARK: UITableViewDataSource

extension AddressesKeysViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func numberOfSections(in _: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath]
        switch row {
        case let .address(address):
            let cell: AddressesKeysValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Waves.Addresseskeys.Cell.Address.title, value: address))
            return cell

        case let .aliases(count):
            let cell: AddressesKeysAliacesCell = tableView.dequeueCell()
            cell.update(with: .init(count: count))
            cell.infoButtonDidTap = { [weak self] in
                self?.eventInput.onNext(.tapShowInfo)
            }
            return cell

        case .hiddenPrivateKey:
            let cell: AddressesKeysHiddenPrivateKeyCell = tableView.dequeueCell()
            cell.showButtonDidTap = { [weak self] in
                self?.eventInput.onNext(.tapShowPrivateKey)
            }
            return cell

        case let .privateKey(key):
            let cell: AddressesKeysValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Waves.Addresseskeys.Cell.Privatekey.title, value: key))
            return cell

        case let .seed(seed):
            let cell: AddressesKeysValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Waves.Addresseskeys.Cell.Seed.title, value: seed))
            return cell

        case let .publicKey(publicKey):
            let cell: AddressesKeysValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: Localizable.Waves.Addresseskeys.Cell.Publickey.title, value: publicKey))
            return cell

        case .skeleton:
            let cell: AddressesKeysSkeletonCell = tableView.dequeueCell()
            return cell
        }
    }
}

// MARK: UITableViewDelegate

extension AddressesKeysViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = sections[indexPath]
        switch row {
        case let .address(address):
            return AddressesKeysValueCell
                .viewHeight(model: .init(title: Localizable.Waves.Addresseskeys.Cell.Address.title, value: address),
                            width: tableView.frame.width)

        case let .aliases(count):
            return AddressesKeysAliacesCell.viewHeight(model: .init(count: count), width: tableView.frame.width)

        case .hiddenPrivateKey:
            return AddressesKeysHiddenPrivateKeyCell.viewHeight(model: (), width: tableView.frame.width)

        case let .seed(seed):
            return AddressesKeysValueCell
                .viewHeight(model: .init(title: Localizable.Waves.Addresseskeys.Cell.Seed.title, value: seed),
                            width: tableView.frame.width)

        case let .privateKey(seed):
            return AddressesKeysValueCell
                .viewHeight(model: .init(title: Localizable.Waves.Addresseskeys.Cell.Privatekey.title, value: seed),
                            width: tableView.frame.width)

        case let .publicKey(publicKey):
            return AddressesKeysValueCell
                .viewHeight(model: .init(title: Localizable.Waves.Addresseskeys.Cell.Publickey.title, value: publicKey),
                            width: tableView.frame.width)

        case .skeleton:
            return AddressesKeysSkeletonCell.viewHeight()
        }
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = sections[indexPath]

        switch row {
        case .skeleton:
            let skeleton = cell as? AddressesKeysSkeletonCell
            skeleton?.startAnimation()

        default:
            break
        }
    }
}

// MARK: UIScrollViewDelegate

extension AddressesKeysViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_: UIScrollView) {
        setupTopBarLine()
    }
}
