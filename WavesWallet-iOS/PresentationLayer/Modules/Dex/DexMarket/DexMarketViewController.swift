//
//  DexMarketViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/9/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

private enum Constants {
    static let searchDelay = 0.3
}

final class DexMarketViewController: UIViewController {

    @IBOutlet private weak var searchBar: SearchBarView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var viewLoadingInfo: UIView!
    @IBOutlet private weak var labelLoadingMarkets: UILabel!
    @IBOutlet private weak var activityIndicatorSearch: UIActivityIndicatorView!
    @IBOutlet private weak var labelNothingHere: UILabel!
    @IBOutlet private weak var viewNothingHere: UIView!
    
    var presenter: DexMarketPresenterProtocol!
    private var modelSection = DexMarket.ViewModel.Section(items: [])
    private let sendEvent: PublishRelay<DexMarket.Event> = PublishRelay<DexMarket.Event>()
    
    weak var delegate: DexMarketDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createBackButton()
        setupLocalization()
        setupViews(isLoadingState: true)
        tableView.keyboardDismissMode = .onDrag
        searchBar.delegate = self
        viewNothingHere.isHidden = true
        
        let feedback = bind(self) { owner, state -> Bindings<DexMarket.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        let readyViewFeedback: DexMarketPresenter.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.rx.viewWillAppear.take(1).map { _ in DexMarket.Event.readyView }.asSignal(onErrorSignalWith: Signal.empty())
        }

        presenter.system(feedbacks: [feedback, readyViewFeedback])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSmallNavigationBar()
        hideTopBarLine()
        navigationItem.isTranslucent = false
    }
}


// MARK: Feedback

fileprivate extension DexMarketViewController {
    func events() -> [Signal<DexMarket.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<DexMarket.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                
                guard let strongSelf = self else { return }
                guard state.action != .none else { return }
                
                strongSelf.setupDefaultState()
                strongSelf.setupViews(isLoadingState: false)
                strongSelf.modelSection = state.section
                strongSelf.tableView.reloadData()
                strongSelf.viewNothingHere.isHidden = state.section.items.count > 0
            })
        
        return [subscriptionSections]
    }
}

//MARK: - Setup UI
private extension DexMarketViewController {
    
    func setupViews(isLoadingState: Bool) {
        searchBar.isHidden = isLoadingState
        viewLoadingInfo.isHidden = !isLoadingState
    }
    
    func setupLocalization() {
        title = Localizable.Waves.Dexmarket.Navigationbar.title
        labelLoadingMarkets.text = Localizable.Waves.Dexmarket.Label.loadingMarkets
        labelNothingHere.text = Localizable.Waves.Dex.General.Error.nothingHere
    }
    
    func setupSearchingState() {
        tableView.isHidden = true
        activityIndicatorSearch.isHidden = false
        activityIndicatorSearch.startAnimating()
    }
    
    func setupDefaultState() {
        tableView.isHidden = false
        activityIndicatorSearch.stopAnimating()
    }
}

//MARK: - UITextFieldDelegate
extension DexMarketViewController: SearchBarViewDelegate {

    @objc private func search(_ searchText: String) {
        sendEvent.accept(.searchTextChange(text: searchText))
    }
    
    func searchBarDidChangeText(_ searchText: String) {
        
        viewNothingHere.isHidden = true
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if searchText.count > 0 {
            setupSearchingState()
            perform(#selector(search(_:)), with: searchText, afterDelay: Constants.searchDelay)
        }
        else {
            search(searchText)
        }
    }
}

//MARK: - UITableViewDelegate
extension DexMarketViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendEvent.accept(.tapCheckMark(index: indexPath.row))
        delegate.dexMarketDidUpdatePairs()
    }
}

//MARK: - UITableViewDataSource
extension DexMarketViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelSection.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = modelSection.items[indexPath.row]
        switch row {
        case .pair(let pair):
            let cell = tableView.dequeueCell() as DexMarketCell
            cell.update(with: pair)
            cell.buttonInfoDidTap = { [weak self] in
                self?.buttonInfoDidTap(indexPath)
            }
            
            return cell
        }
    }
}

//MARK: - DexMarketCellActions

private extension DexMarketViewController {
    
    func buttonInfoDidTap(_ indexPath: IndexPath) {
        sendEvent.accept(.tapInfoButton(index: indexPath.row))        
    }
}
