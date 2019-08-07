//
//  AssetsSearchViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 05.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift

private enum Constants {
    static let headerHeight: CGFloat = 74
    static let cellHeight: CGFloat = 64
    static let bottomInset: CGFloat = 16
}

private typealias Types = AssetsSearch

final class AssetsSearchViewController: ModalScrollViewController {
    
    @IBOutlet var tableView: ModalTableView!
    
    override var scrollView: UIScrollView {
        return tableView
    }
    
    private var rootView: ModalRootView {
        return view as! ModalRootView
    }
    
    private var headerView: AssetsSearchHeaderView = AssetsSearchHeaderView.loadView()
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private var selectedElementsMap: [String: ActionSheet.DTO.Element] = .init()
    
    var elementDidSelect: ((ActionSheet.DTO.Element) -> Void)?
    
    var system: System<AssetsSearch.State, AssetsSearch.Event>!
    
    var moduleOuput: AssetsSearchModuleOutput?
    
    fileprivate var state: AssetsSearch.State.UI?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.delegate = self
        headerView.searchBarView.delegate = self
        system
            .start()
            .drive(onNext: { [weak self] (state) in
                guard let self = self else { return }
                self.update(state: state.core)
                self.update(state: state.ui)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        system.send(.viewDidAppear)
        _ = headerView.searchBarView.becomeFirstResponder()                                
    }
    
    override func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        
        return size.height - (findNavigationController()?.topViewController?.layoutInsets.top ?? 0)
    }
    
    override func bottomScrollInset(for size: CGSize) -> CGFloat {
        return Constants.bottomInset
    }
}

// MARK: System

private extension AssetsSearchViewController {
    
    private func update(state: Types.State.Core) {
        
        switch state.action {
        case .selected(let assets):
            moduleOuput?.assetsSearchSelectedAssets(assets)
        default:
            break
        }
    }
    
    private func update(state: Types.State.UI) {
        
        self.state = state
        
        headerView.searchBarView.stopLoading()
        
        switch state.action {
        case .update:
            tableView.reloadData()
            
            headerView.keyboardControl.update(with: .init(title: "\(state.countSelectedAssets) \\ \(state.limitSelectAssets)"))
            
        case .loading:
            headerView.searchBarView.startLoading()
            
        default:
            break
        }
    }
}

extension AssetsSearchViewController: SearchBarViewDelegate {
    
    func searchBarDidChangeText(_ searchText: String) {
        self.system.send(.search(searchText))
    }
}

// MARK: ModalRootViewDelegate

extension AssetsSearchViewController: ModalRootViewDelegate {
    
    func modalHeaderView() -> UIView {
        return headerView
    }
    
    func modalHeaderHeight() -> CGFloat {
        return Constants.headerHeight
    }
}

// MARK: UITableViewDataSource

extension AssetsSearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let row = state?[indexPath] else { return UITableViewCell() }
        
        switch row {
        case .asset(let model):
            let cell: AssetsSearchAssetCell = tableView.dequeueCell()
            cell.update(with: model)
            return cell
        case .empty:
            let cell: AssetsSearchEmptyCell = tableView.dequeueCell()            
            return cell
        }        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return state?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state?[section].rows.count ?? 0
    }
}

// MARK: UITableViewDelegate

extension AssetsSearchViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        system.send(.select(indexPath))
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        rootView.scrollViewDidScroll(scrollView)
        
        let yOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        
        if yOffset > scrollView.contentInset.top {
            headerView.isHiddenSepatator = false
        } else {
            headerView.isHiddenSepatator = true
        }
    }
}

