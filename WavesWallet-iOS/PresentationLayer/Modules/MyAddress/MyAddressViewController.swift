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

final class MyAddressViewController: UIViewController {

    typealias Types = MyAddressTypes

    @IBOutlet private var tableView: UITableView!

    private var sections: [Types.ViewModel.Section] = []
    private var eventInput: PublishSubject<Types.Event> = PublishSubject<Types.Event>()
    
    var presenter: MyAddressPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()
        navigationItem.backgroundImage = UIImage()
        navigationItem.shadowImage = UIImage()

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
           edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        }

        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        
        setupSystem()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset  = UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
    }
}

// MARK: RxFeedback

private extension MyAddressViewController {

    func setupSystem() {

        let uiFeedback: MyAddressPresenterProtocol.Feedback = bind(self) { (owner, state) -> (Bindings<Types.Event>) in
            return Bindings(subscriptions: owner.subscriptions(state: state), mutations: owner.events())
        }

        let readyViewFeedback: MyAddressPresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf.rx.viewWillAppear.asObservable()
                .throttle(1, scheduler: MainScheduler.instance)
                .asSignal(onErrorSignalWith: Signal.empty())
                .map { _ in Types.Event.viewWillAppear }
        }

        let viewDidDisappearFeedback: MyAddressPresenterProtocol.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }

            return strongSelf.rx.viewDidDisappear.asObservable()
                .throttle(1, scheduler: MainScheduler.instance)
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

extension MyAddressViewController: UITableViewDataSource {

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
            let cell: MyAddressInfoAddressCell = tableView.dequeueCell()

            cell.update(with: .init(address: address))
            return cell

        case .aliases(let count):
            let cell: MyAddressAliacesCell = tableView.dequeueCell()
            cell.update(with: .init(count: count))
            cell.infoButtonDidTap = { [weak self] in
                self?.eventInput.onNext(.tapShowInfo)
            }
            return cell

        case .qrcode(let address):
            let cell: MyAddressQRCodeCell = tableView.dequeueCell()
            cell.update(with: .init(address: address))

            return cell

        case .skeleton:
            let cell: MyAddressAliacesSkeletonCell = tableView.dequeueCell()
            return cell
        }
    }
}

// MARK: UITableViewDelegate

extension MyAddressViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let row = sections[indexPath]
        switch row {
        case .address:
            return MyAddressInfoAddressCell.viewHeight()

        case .aliases:
            return MyAddressAliacesCell.viewHeight()

        case .qrcode:
            return MyAddressQRCodeCell.viewHeight()

        case .skeleton:
            return MyAddressAliacesSkeletonCell.viewHeight()
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let row = sections[indexPath]

        switch row {
        case .skeleton:
            let skeleton = cell as? MyAddressAliacesSkeletonCell
            skeleton?.startAnimation()

        default:
            break
        }
    }
}
