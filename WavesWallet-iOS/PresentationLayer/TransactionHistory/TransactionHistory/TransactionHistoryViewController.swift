//
//  TransactionHistoryViewController.swift
//  WavesWallet-iOS
//
//  Created by Mac on 22/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import SwipeView
import RxCocoa
import RxFeedback
import RxSwift
 
class TransactionHistoryViewController: UIViewController {
    
    @IBOutlet weak var swipeView: SwipeView!
    
    var presenter: TransactionHistoryPresenter!
    
    private var displays: [TransactionHistoryTypes.State.DisplayState] = []
    
    let accountTap: PublishSubject<DomainLayer.DTO.SmartTransaction> = PublishSubject<DomainLayer.DTO.SmartTransaction>()
    let buttonTap: PublishSubject<DomainLayer.DTO.SmartTransaction> = PublishSubject<DomainLayer.DTO.SmartTransaction>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipeView.delegate = self
        swipeView.dataSource = self
        
        setupSystem()
    }
    
}

// MARK: - Bind UI

private extension TransactionHistoryViewController {
    
    func setupSystem() {
        
        let feedback: TransactionHistoryPresenterProtocol.Feedback = bind(self) { owner, state in
        
            let subscriptions = owner.uiSubscriptions(state: state)
            let events = owner.events()
            
            return Bindings(subscriptions: subscriptions, events: events)
            
        }
        
        let readyViewFeedback: TransactionHistoryPresenter.Feedback = { [weak self] _ in
            guard let sself = self else { return Signal.empty() }
            return sself
                .rx
                .viewWillAppear
                .take(1)
                .map { _ in TransactionHistoryTypes.Event.readyView }
                .asSignal(onErrorSignalWith: Signal.empty())
        }
        
        presenter.system(feedbacks: [feedback, readyViewFeedback])
        
    }
    
    func events() -> [Signal<TransactionHistoryTypes.Event>] {
        
        return []
        
    }
    
    func uiSubscriptions(state: Driver<TransactionHistoryTypes.State>) -> [Disposable] {
        
        let subscriptionSections = state.drive(onNext: { [weak self] (state) in
            
            guard let sself = self else { return }
            
            sself.displays = state.displays
            sself.swipeView.reloadData()
            
            sself.swipeView.currentPage = state.currentIndex
        })
        
        return [subscriptionSections]
        
    }
    
}

extension TransactionHistoryViewController: SwipeViewDelegate {
    
    func swipeViewCurrentItemIndexDidChange(_ swipeView: SwipeView!) {
        
    }
    
}

extension TransactionHistoryViewController: TransactionHistoryContentViewDelegate {
    
    func contentViewDidPressButton(view: NewTransactionHistoryContentView) {
        
        let transaction = displays[swipeView.currentItemIndex].sections[0].transaction
        buttonTap.onNext(transaction)
        
    }
    
    func contentViewDidPressAccount(view: NewTransactionHistoryContentView) {
        
        let transaction = displays[swipeView.currentItemIndex].sections[0].transaction
        accountTap.onNext(transaction)
        
    }
    
}

extension TransactionHistoryViewController: SwipeViewDataSource {
    
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        return displays.count
    }
    
    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        
        let displayState = displays[index]
        
        let view = NewTransactionHistoryContentView.loadView() as! NewTransactionHistoryContentView 
        view.frame = swipeView.bounds
        view.setup(with: displayState)
        view.delegate = self
        
        return view
        
    }
    
}
