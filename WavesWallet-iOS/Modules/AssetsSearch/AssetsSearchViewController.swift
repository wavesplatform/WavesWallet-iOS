//
//  AssetsSearchViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 05.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import Extensions

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
    
    @IBOutlet fileprivate var keyboardControlAccessoryView: KeyboardControl!
    @IBOutlet fileprivate var keyboardControl: KeyboardControl!
    
    private var keyboardControlTransfromation: Bool = false
    
    var elementDidSelect: ((ActionSheet.DTO.Element) -> Void)?
    
    var system: System<AssetsSearch.State, AssetsSearch.Event>!
    
    var moduleOuput: AssetsSearchModuleOutput?
    
    fileprivate var state: AssetsSearch.State.UI?
    fileprivate var snackError: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.delegate = self
        
        headerView.searchBarView.delegate = self
        headerView.searchBarView.textField.inputAccessoryView = keyboardControlAccessoryView
        
        keyboardControlAccessoryView.delegate = self
        keyboardControl.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        system
            .start()
            .drive(onNext: { [weak self] (state) in
                guard let self = self else { return }
                self.update(state: state.core)
                self.update(state: state.ui)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = headerView.searchBarView.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        system.send(.viewDidAppear)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _ = headerView.searchBarView.resignFirstResponder()
    }
    
    override func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        let layoutInsets = (findNavigationController()?.layoutInsets.top ?? 0)
        return size.height - layoutInsets
    }
    
    override func bottomScrollInset(for size: CGSize) -> CGFloat {
        return Constants.bottomInset + layoutInsets.bottom
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        keyboardControlAccessoryView.hasDissmissKeyboardButton = true
        keyboardControl.hasDissmissKeyboardButton = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        keyboardControlAccessoryView.hasDissmissKeyboardButton = false
        keyboardControl.hasDissmissKeyboardButton = false
        
        if keyboardControlTransfromation == true {
            return
        }
        keyboardControlTransfromation = true
        
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        guard let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else { return }
        let keyboardRectangle = keyboardFrame.cgRectValue
        let options = UIView.AnimationOptions(rawValue: UInt(curve) << 16 | UIView.AnimationOptions.beginFromCurrentState.rawValue)
        
        // KeyboardControl remove from inputAccessoryView.
        DispatchQueue.main.async {
            self.headerView.searchBarView.textField.inputAccessoryView = nil
            self.headerView.searchBarView.textField.reloadInputViews()
            self.keyboardControlAccessoryView.removeFromSuperview()
            self.keyboardControlAccessoryView.layer.removeAllAnimations()
        }
        
        // Initial state
        var frame = keyboardControlAccessoryView.frame
        frame.origin.y = view.frame.height - keyboardRectangle.height
        keyboardControlAccessoryView.frame = frame
        keyboardControlAccessoryView.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(keyboardControlAccessoryView)
        self.keyboardControl.alpha = 0
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            
            var frame = self.keyboardControlAccessoryView.frame
            frame.origin.y = 0
            self.keyboardControlAccessoryView.frame = self.keyboardControl.frame
        }) { (animated) in
            self.keyboardControl.alpha = 1
            self.keyboardControlAccessoryView.translatesAutoresizingMaskIntoConstraints = false
            self.keyboardControlAccessoryView.removeFromSuperview()
            self.headerView.searchBarView.textField.inputAccessoryView = self.keyboardControlAccessoryView
            self.headerView.searchBarView.textField.reloadInputViews()
            self.keyboardControlTransfromation = false
        }
    }
    
    private func showErrorView(with error: DisplayError) {
        
        switch error {
        case .globalError:
            snackError = showWithoutInternetSnack()
            
        case .internetNotWorking:
            snackError = showWithoutInternetSnack()
            
        case .message(let message):
            snackError = showErrorSnack(message)
            
        default:
            snackError = showErrorNotFoundSnack()
            
        }
    }
    
    private func showWithoutInternetSnack() -> String {
        return showWithoutInternetSnack { [weak self] in
            self?.system.send(.refresh)
        }
    }
    
    private func showErrorSnack(_ message: (String)) -> String {
        return showErrorSnack(title: message, didTap: { [weak self] in
            self?.system.send(.refresh)
        })
    }
    
    private func showErrorNotFoundSnack() -> String {
        return showErrorNotFoundSnack() { [weak self] in
            self?.system.send(.refresh)
        }
    }
}

// MARK: KeyboardControlDelegate

extension AssetsSearchViewController: KeyboardControlDelegate {
    
    func keyboardControlDidTapKeyboardButton(hasDissmissKeyboardButton: Bool) {
        
        if hasDissmissKeyboardButton {
            _ = headerView.searchBarView.resignFirstResponder()
            view.endEditing(true)
        } else {
            _ = headerView.searchBarView.becomeFirstResponder()
        }
        
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
        if let snackError = self.snackError {
            hideSnack(key: snackError)
        }
        
        switch state.action {
        case .update:
            tableView.reloadData()
            keyboardControl.update(with: .init(title: "\(state.countSelectedAssets) / \(state.maxSelectAssets)"))
            keyboardControlAccessoryView.update(with: .init(title: "\(state.countSelectedAssets) / \(state.maxSelectAssets)"))
            
        case .loading:
            headerView.searchBarView.startLoading()
            
        case .error(let error):
            self.view.endEditing(true)
            showErrorView(with: error)
            
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

