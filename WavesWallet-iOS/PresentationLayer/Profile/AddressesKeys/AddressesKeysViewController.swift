//
//  AddressesKeysViewController.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 25/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxFeedback
import RxSwift
import RxCocoa

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
        navigationItem.title = "Addresses, keys"
        navigationItem.barTintColor = .white

        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        
//        sections = [Types.ViewModel.Section.init(rows: [.aliases(8),
//                                                        .address("3PCjZftzzhtY4ZLLBfsyvNxw8RwAgXZVZJW"),
//                                                        .publicKey("4T25bAunzydwvzkJcQ9f378UzGRqyUcDXLS4xgam7JQQ 4T25bAunzydwvzkJcQ9f378UzGRqyUcDXLS4xgam7JQQ"),
//                                                        .hiddenPrivateKey])]

//        tableView.reloadData()

        setupSystem()
    }
}

// MARK: RxFeedback

private extension AddressesKeysViewController {

    func setupSystem() {

        let uiFeedback: AddressesKeysPresenterProtocol.Feedback = bind(self) { (owner, state) -> (Bindings<Types.Event>) in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        let readyViewFeedback: AddressesKeysPresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf.rx.viewWillAppear.asObservable()
                .throttle(1, scheduler: MainScheduler.instance)
                .asSignal(onErrorSignalWith: Signal.empty())
                .map { _ in Types.Event.viewWillAppear }
        }

        presenter.system(feedbacks: [uiFeedback, readyViewFeedback])
    }

    func events() -> [Signal<Types.Event>] {
        return [eventInput.asSignal(onErrorSignalWith: Signal.empty())]
    }

    func subscriptions(state: Driver<Types.State>) -> [Disposable] {

        let subscriptionSections = state.drive(onNext: { [weak self] state in

            guard let strongSelf = self else { return }

            strongSelf.updateView(with: state.displayState)
        })

        return [subscriptionSections]
    }

    func updateView(with state: Types.DisplayState) {

        self.sections = state.sections
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let row = sections[indexPath]
        switch row {
        case .address(let address):
            let cell: AddressesKeysValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: "Your address", value: address))
            return cell

        case .aliases(let count):
            let cell: AddressesKeysAliacesCell = tableView.dequeueCell()
            cell.update(with: .init(count: count))
            return cell

        case .hiddenPrivateKey:
            let cell: AddressesKeysHiddenPrivateKeyCell = tableView.dequeueCell()
            cell.showButtonDidTap = { [weak self] in
                self?.eventInput.onNext(.tapShowPrivateKey)
            }
            return cell

        case .privateKey(let seed):
            let cell: AddressesKeysValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: "Private Key", value: seed))
            return cell

        case .publicKey(let publicKey):
            let cell: AddressesKeysValueCell = tableView.dequeueCell()
            cell.update(with: .init(title: "Public Key", value: publicKey))
            return cell

        case .skeleton:
            let cell: AddressesKeysSkeletonCell = tableView.dequeueCell()
            return cell
        }
    }
}

// MARK: UITableViewDelegate

extension AddressesKeysViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let row = sections[indexPath]
        switch row {
        case .address(let address):
            return AddressesKeysValueCell.viewHeight(model: .init(title: "Your address", value: address), width: tableView.frame.width)

        case .aliases(let count):
            return AddressesKeysAliacesCell.viewHeight(model: .init(count: count), width: tableView.frame.width)

        case .hiddenPrivateKey:
            return AddressesKeysHiddenPrivateKeyCell.viewHeight(model: (), width: tableView.frame.width)

        case .privateKey(let seed):
            return AddressesKeysValueCell.viewHeight(model: .init(title: "Your address", value: seed), width: tableView.frame.width)

        case .publicKey(let publicKey):
            return AddressesKeysValueCell.viewHeight(model: .init(title: "Public Key", value: publicKey), width: tableView.frame.width)

        case .skeleton:
            return AddressesKeysSkeletonCell.viewHeight(model: (), width: tableView.frame.width)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
