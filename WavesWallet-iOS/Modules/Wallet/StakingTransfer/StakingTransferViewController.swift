//
//  StakingTransferViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import WavesSDKExtensions
import DomainLayer
import RxSwift
import IQKeyboardManagerSwift

private typealias Types = StakingTransfer

extension UIViewController {
    
    func addViewController(viewController: UIViewController, rootView: UIView) {
        
        guard let view = viewController.view else { return }
        self.addChild(viewController)
        rootView.addSubview(view)
        viewController.didMove(toParent: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: rootView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: rootView.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: rootView.rightAnchor).isActive = true
    }
}

protocol StakingTransferModuleOutput: AnyObject {
    func stakingTransferOpenURL(_ url: URL)
    func stakingTransferDidSendCard(url: URL, amount: DomainLayer.DTO.Balance)
    func stakingTransferDidSendWithdraw(transaction: DomainLayer.DTO.SmartTransaction, amount: DomainLayer.DTO.Balance)
    func stakingTransferDidSendDeposit(transaction: DomainLayer.DTO.SmartTransaction, amount: DomainLayer.DTO.Balance)
}

private enum Constants {
    static let headerHeight: CGFloat = 82
    static let cardContentHight: CGFloat = 480
    static let transferContentHeght: CGFloat = 450
}

final class StakingTransferViewController: ModalScrollViewController {
    
    @IBOutlet var tableView: ModalTableView!
    
    override var scrollView: UIScrollView {
        return tableView
    }
    
    private var rootView: ModalRootView {
        return view as! ModalRootView
    }
    
    private lazy var stakingTransferHeaderView: StakingTransferHeaderView = StakingTransferHeaderView.loadFromNib()
    
    private let disposeBag: DisposeBag = DisposeBag()
        
    var system: System<StakingTransfer.State, StakingTransfer.Event>!
    
    private var sections: [Types.ViewModel.Section] = .init()
    
    private var kind: StakingTransfer.DTO.Kind? = nil
    
    private var snackBarKey: String? = nil
    
    private var saveOldContentInset: UIEdgeInsets?
    private var saveOldContentOffset: CGPoint?
    
    weak var moduleOutput: StakingTransferModuleOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        rootView.delegate = self
        
        self.navigationItem.isNavigationBarHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
                        
        setupUI()
        
        system
            .start()
            .drive(onNext: { [weak self] (state) in
                guard let self = self else { return }
                self.update(state: state.ui)
            })
            .disposed(by: disposeBag)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        system.send(.viewDidDisappear)
        
        IQKeyboardManager.shared.enable = true
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        system.send(.viewDidAppear)        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(StakingTransferViewController.self)
    }
    
    private func setupUI() {
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
    }
    
    override func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        
        guard let kind = self.kind else { return size.height }
        
        switch kind {
        case .card:
            return Constants.cardContentHight
            
        case .deposit, .withdraw:
            return Constants.transferContentHeght
        }
    }
    
    override func bottomScrollInset(for size: CGSize) -> CGFloat {
        return 0
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        guard let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else { return }
        let keyboardRectangle = keyboardFrame.cgRectValue
        let options = UIView.AnimationOptions(rawValue: UInt(curve) << 16 | UIView.AnimationOptions.beginFromCurrentState.rawValue)
        
        guard let cell = tableView.visibleCells.first(where: { (cell) -> Bool in
            return cell is StakingTransferInputFieldCell
        }) as? StakingTransferInputFieldCell else { return }
                        
        let cellFrame = cell.frame
        
        guard keyboardRectangle.intersects(cellFrame) == true else { return }
                        
        // I calculate distance between keyboard and cell and shift table to top
        let offSetY = keyboardRectangle.maxY - cellFrame.midY

        
        self.saveOldContentInset = self.tableView.contentInset
        self.saveOldContentOffset = self.tableView.contentOffset
        
        SweetLogger.debug("save contentInset \(self.tableView.contentInset)")
                                    
        self.tableView.contentInset.bottom = offSetY
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                        
            self.tableView.contentOffset.y = self.tableView.contentOffset.y + offSetY
        }) { (animated) in }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
                
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        guard let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else { return }
        let options = UIView.AnimationOptions(rawValue: UInt(curve) << 16 | UIView.AnimationOptions.beginFromCurrentState.rawValue)
                                
        self.tableView.contentInset.bottom = self.saveOldContentInset?.bottom ?? self.tableView.contentInset.bottom
                
        SweetLogger.debug("restore contentInset \(self.saveOldContentInset ?? UIEdgeInsets.zero)")
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.tableView.contentOffset.y = self.saveOldContentOffset?.y ?? self.tableView.contentOffset.y
        }) { (animated) in }
        
        self.saveOldContentOffset = nil
        self.saveOldContentInset = nil
    }
}

// MARK: Private
extension StakingTransferViewController {
    
    private func update(state: StakingTransfer.State.UI) {
        
        self.sections = state.sections
        self.kind = state.kind
        
        stakingTransferHeaderView.update(with: .init(title: state.title))
        
        switch state.action {
        case .none:
            break
            
        case .completedDeposit(_ , let tx, let amount):
            self.moduleOutput?.stakingTransferDidSendDeposit(transaction: tx, amount: amount)
        
        case .completedWithdraw(_, let tx, let amount):
            self.moduleOutput?.stakingTransferDidSendWithdraw(transaction: tx, amount: amount)
            
        case .completedCard(_, let url, let amount):
            self.moduleOutput?.stakingTransferDidSendCard(url: url, amount: amount)
            
        case .update(let updateRows, _):
            
            if updateRows == nil {
                tableView.reloadData()
            }
        }
                    
        if let updateRows = state.action.updateRoes {
            let insertRows = updateRows.insertRows
            let deleteRows = updateRows.deleteRows
            let reloadRows = updateRows.reloadRows
            let updateRows = updateRows.updateRows
                                                 
            let needUpdateTable = (deleteRows.count + insertRows.count + reloadRows.count) > 0
            
            if needUpdateTable {
                tableView.beginUpdates()
                
                if deleteRows.count > 0 {
                    tableView.deleteRows(at: deleteRows, with: .fade)
                }
                
                if insertRows.count > 0 {
                    tableView.insertRows(at: insertRows, with: .fade)
                }
                
                if reloadRows.count > 0 {
                    tableView.reloadRows(at: reloadRows, with: .none)
                }
                
                tableView.endUpdates()
            }
            
            updateRows.forEach { updateCellByModel(indexPath: $0) }
            
        }
        
        if let displayError = state.action.displayError {
            
            if let snackBar = snackBarKey {
                hideSnack(key: snackBar)
            }
            
            switch displayError {
            case .message(let message):
                snackBarKey = showErrorSnackWithoutAction(title: message)
                
            default:
                snackBarKey = showErrorNotFoundSnackWithoutAction()
            }
        }
        
    }
    
    private func updateCellByModel(indexPath: IndexPath) {
        
        let model = self.sections[indexPath]
        
        switch model {
        case .inputField(let model):
            
            guard let cell  = tableView.cellForRow(at: indexPath) as? StakingTransferInputFieldCell else { return }
            cell.update(with: model)
            
        case .button(let model):
            guard let cell  = tableView.cellForRow(at: indexPath) as? StakingTransferButtonCell else { return }
            cell.update(with: model)
            
        default:
            break
        }
    }
}

// MARK: ModalRootViewDelegate

extension StakingTransferViewController: ModalRootViewDelegate {
    
    func modalHeaderView() -> UIView {
        stakingTransferHeaderView
    }
    
    func modalHeaderHeight() -> CGFloat {
        Constants.headerHeight
    }
}

// MARK: UITableViewDataSource

extension StakingTransferViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = sections[indexPath]
        
        switch row {
            
        case .skeletonBalance:
            
            let cell: StakingTransferSkeletonBalanceCell = tableView.dequeueAndRegisterCell(indexPath: indexPath)
            return cell
            
        case .balance(let model):
            
            let cell: StakingTransferBalanceCell = tableView.dequeueAndRegisterCell(indexPath: indexPath)
            cell.update(with: model)
            return cell
            
        case .inputField(let model):
            
            let cell: StakingTransferInputFieldCell = tableView.dequeueAndRegisterCell(indexPath: indexPath)
            cell.update(with: model)
            
            cell.didSelectLinkWith = { [weak self] url in
                self?.moduleOutput?.stakingTransferOpenURL(url)
            }
            
            cell.didChangeInput = { [weak self] money in
                self?.system.send(.input(money, indexPath))
            }
            
            cell.didTapButtonDoneOnKeyboard = { [weak self] in
                self?.system.send(.tapSendButton)
            }
            
            return cell
            
        case .button(let model):
            
            let cell: StakingTransferButtonCell = tableView.dequeueAndRegisterCell(indexPath: indexPath)
            cell.update(with: model)
            
            cell.didTouchButton = { [weak self] in
                self?.system.send(.tapSendButton)
            }
                        
            return cell
            
        case .scrollButtons(let model):
            
            let cell: StakingTransferScrollButtonsCell = tableView.dequeueAndRegisterCell(indexPath: indexPath)
            cell.update(with: model)
            cell.didTapView = { [weak self, weak cell] index in
                
                if let value = cell?.value(for: index),
                    let assistanceButton = StakingTransfer.DTO.AssistanceButton.init(rawValue: value) {
                    self?.system.send(.tapAssistanceButton(assistanceButton))
                }
            }
            return cell
            
        case .error(let model):
            
            let cell: StakingTransferErrorCell = tableView.dequeueAndRegisterCell(indexPath: indexPath)
            cell.update(with: model)
            return cell
            
        case .feeInfo(let model):
            
            let cell: StakingTransferFeeInfoCell = tableView.dequeueAndRegisterCell(indexPath: indexPath)
            cell.update(with: model)
            return cell
            
        case .description(let model):
            
            let cell: StakingTransferDescriptionCell = tableView.dequeueAndRegisterCell(indexPath: indexPath)
            cell.update(with: model)
            cell.didSelectLinkWith = { [weak self] url in
                self?.moduleOutput?.stakingTransferOpenURL(url)
            }
            return cell
            
        }
    }
}

// MARK: UITableViewDelegate

extension StakingTransferViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let row = sections[indexPath]
        switch row {
        case .skeletonBalance:
            
            let cell = cell as? StakingTransferSkeletonBalanceCell
            cell?.startAnimation()
            
        default:
            break
        }
    }
}

extension StakingTransferViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        let yOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        
        if yOffset > scrollView.contentInset.top {
            stakingTransferHeaderView.isHiddenSepatator = false
        } else {
            stakingTransferHeaderView.isHiddenSepatator = true
        }
    }
}
