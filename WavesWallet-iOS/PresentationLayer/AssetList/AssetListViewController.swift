//
//  AssetListViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/4/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

final class AssetListViewController: UIViewController {

    @IBOutlet private weak var searchBar: SearchBarView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var viewLoading: UIView!
    @IBOutlet private weak var labelLoading: UILabel!
    
    private var modelSection = AssetList.ViewModel.Section(items: [])
    private var isSearchMode: Bool = false
    private let sendEvent: PublishRelay<AssetList.Event> = PublishRelay<AssetList.Event>()

    var selectedAsset: DomainLayer.DTO.AssetBalance?
    var presenter: AssetListPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
        createBackButton()
        setupFeedBack()
        setupLoadingState()
        searchBar.delegate = self
        tableView.keyboardDismissMode = .onDrag
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSmallNavigationBar()
        hideTopBarLine()
        navigationItem.backgroundImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backgroundImage = nil
    }
}


// MARK: Feedback

private extension AssetListViewController {
    
    func setupFeedBack() {
        
        let feedback = bind(self) { owner, state -> Bindings<AssetList.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }
        
        let readyViewFeedback: AssetListPresenter.Feedback = { [weak self] _ in
            guard let strongSelf = self else { return Signal.empty() }
            return strongSelf.rx.viewWillAppear.take(1).map { _ in AssetList.Event.readyView }.asSignal(onErrorSignalWith: Signal.empty())
        }
        presenter.system(feedbacks: [feedback, readyViewFeedback])
    }
    
    func events() -> [Signal<AssetList.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<AssetList.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                print(state)
                guard let strongSelf = self else { return }
                guard state.action != .none else { return }
                strongSelf.modelSection = state.section
                strongSelf.tableView.reloadData()
                strongSelf.setupDefaultState()
            })
        
        return [subscriptionSections]
    }
}


//MARK: - SearchBarViewDelegate
extension AssetListViewController: SearchBarViewDelegate {
    func searchBarDidChangeText(_ searchText: String) {
        sendEvent.accept(.searchTextChange(text: searchText))
    }
}

//MARK: - UITableViewDelegate
extension AssetListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let asset = modelSection.items[indexPath.row].asset
        sendEvent.accept(.didSelectAsset(asset))
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - UITableViewDataSource
extension AssetListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelSection.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueCell() as AssetListTableViewCell
       
        let assetBalance = modelSection.items[indexPath.row].asset
        
        if let asset = assetBalance.asset {
            let isChecked = assetBalance.assetId == selectedAsset?.assetId
            let money = Money(assetBalance.balance, asset.precision)
            let isFavourite = assetBalance.settings?.isFavorite ?? false
            
            cell.update(with: .init(asset: asset, balance: money, isChecked: isChecked, isFavourite: isFavourite))
        }
        return cell
    }
}

//MARK: - SetupUI
private extension AssetListViewController {
    
    func setupLocalization() {
        title = Localizable.AssetList.Label.assets
        labelLoading.text = Localizable.AssetList.Label.loadingAssets
    }
    
    func setupLoadingState() {
        viewLoading.isHidden = false
        tableView.isHidden = true
        searchBar.isHidden = true
    }
    
    func setupDefaultState() {
        viewLoading.isHidden = true
        tableView.isHidden = false
        searchBar.isHidden = false
    }
    
}
