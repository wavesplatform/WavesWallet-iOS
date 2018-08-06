//
//  NewHistoryViewController.swift
//  WavesWallet-iOS
//
//  Created by Mac on 02/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxCocoa
import RxDataSources
import RxFeedback
import RxSwift

final class NewHistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: WalletSegmentedControl!
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let displays: [HistoryTypes.Display] = [.all, .sent, .received, .exchanged, .leased, .issued, .activeNow, .canceled]
    
    var presenter: HistoryPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "History"

        setupSystem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
}

// MARK: Bind UI

private extension NewHistoryViewController {
    
    func setupSystem() {
        
        let feedback: HistoryPresenterProtocol.Feedback = bind(self) { owner, state in
            
            let subscriptions = owner.uiSubscriptions(state: state)
            let events = owner.events()
            
            return Bindings(subscriptions: subscriptions,
                            events: events)
        }
        
        let readyViewFeedback: HistoryPresenter.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf
                .rx
                .viewWillAppear
                .take(1)
                .map { _ in HistoryTypes.Event.readyView }
                .asSignal(onErrorSignalWith: Signal.empty())
        }
        
        presenter.system(feedbacks: [feedback,
                                     readyViewFeedback])
        
    }
    
    func events() -> [Signal<HistoryTypes.Event>] {
        
        let changedDisplayEvent = segmentedControl.changedValue()
            .map { [weak self] selectedIndex -> HistoryTypes.Event in
                
                let display = self?.displays[selectedIndex] ?? .all
                return .changeDisplay(display)
        }
        
        return [changedDisplayEvent]
    }
    
    func uiSubscriptions(state: Driver<HistoryTypes.State>) -> [Disposable] {
        return []
    }
    
}

// MARK: - Setup

extension NewHistoryViewController {
    
    func setupSegmetedControl() {
        //        let buttons = displays.map { SegmentedControl.Button(name: $0.name) }
        //        segmentedControl
        //            .segmentedControl
        //            .update(with: buttons, animated: true)
    }
    
}

extension NewHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

extension NewHistoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WalletAssetSkeletonCell = tableView.dequeueCell()
        
        return cell
    }
    
}
