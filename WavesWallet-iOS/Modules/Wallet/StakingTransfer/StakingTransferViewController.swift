//
//  StakingTransferViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import RxSwift

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
}


final class StakingTransferViewController: UIViewController, ModalTableControllerDelegate {
        
    private let modalTableViewController: ModalTableViewController = ModalTableViewController.create()
    
    private var tableView: UITableView {
        return modalTableViewController.tableView
    }
    
    private lazy var stakingTransferHeaderView: StakingTransferHeaderView = StakingTransferHeaderView.loadFromNib()
        
    private let disposeBag: DisposeBag = DisposeBag()
           
    //TODO: Change module builde
    private var system: System<StakingTransfer.State, StakingTransfer.Event>! = StakingTransferSystem()
    
    private var sections: [Types.ViewModel.Section] = .init()
    
    weak var moduleOutput: StakingTransferModuleOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViewController(viewController: modalTableViewController, rootView: view)
        modalTableViewController.delegate = self
        modalTableViewController.tableDelegate = self
        modalTableViewController.tableDataSource = self
        
        stakingTransferHeaderView.translatesAutoresizingMaskIntoConstraints = true
        
        
        setupUI()
        
        system
            .start()
            .drive(onNext: { [weak self] (state) in
                guard let self = self else { return }
                self.update(state: state.ui)
            })
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        system.send(.viewDidAppear)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        system.send(.viewDidAppear)
    }
    
    private func setupUI() {
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
    }
}

extension StakingTransferViewController {
    
    private func update(state: StakingTransfer.State.UI) {
                        
        self.sections = state.sections
        
        stakingTransferHeaderView.update(with: .init(title: state.title))
        
        switch state.action {
        case .none:
            break
            
        case .update:
                                                
            tableView.reloadData()
            self.modalTableViewController.setNeedUpdateInset(animated: true)

                                            
        case .updateRows(let insertRows, let deleteRows, let reloadRows, let updateRows):
               
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
                                    
        case .error(let networkError):
            break
            
        default:
            break
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
    
extension StakingTransferViewController {
    
    func modalHeaderView() -> UIView {
        return stakingTransferHeaderView
    }

    func modalHeaderHeight() -> CGFloat {
        return 82
    }
    
    func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        return sections.count == 0 ? size.height : tableView.contentSize.height
    }
    
    func bottomScrollInset(for size: CGSize) -> CGFloat {
        return 0
    }
}

extension StakingTransferViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].rows.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = sections[indexPath]
        
        switch row {
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
            return cell
            
        }
        
//        switch indexPath.row {
//
//        case 0:
//            let cell: StakingTransferBalanceCell? = tableView.dequeueAndRegisterCell(indexPath: indexPath)
//
//            cell?.update(with: .init(assetURL: .init(assetId: "WAVES",
//                                                     name: "WAVES",
//                                                     url: nil,
//                                                     isSponsored: false,
//                                                     hasScript: false),
//                                     title: "Test",
//                                     money: Money(10000000, 100)))
//
//            return cell!
//        case 1:
//            let cell: StakingTransferInputFieldCell? = tableView.dequeueAndRegisterCell(indexPath: indexPath)
//
//            let fullText = "Deposit to Smart Contract"
//
//            let url = URL.init(string: "HTTP://ya.ru")!
//
//            let string = NSMutableAttributedString(string: fullText)
//            string.addAttributes([NSAttributedString.Key.link: url], range: fullText.nsRange(of: "Contract")!)
//
//            cell?.update(with: .init(title: string,
//                                     balance: .init(style: .normal,
//                                                    state: .empty(6,
//                                                                  .init(title: "USDN",
//                                                                        ticker: "USDN")))))
//
//            return cell!
//
//        case 2:
//            let cell: StakingTransferInputFieldCell? = tableView.dequeueAndRegisterCell(indexPath: indexPath)
//
//
//
//            return cell!
//        case 3:
//            let cell: StakingTransferErrorCell? = tableView.dequeueAndRegisterCell(indexPath: indexPath)
//
//            cell?.update(with: .init(title: "Min value is 10 USDN"))
//
//            return cell!
//
//        case 4:
//            let cell: StakingTransferScrollButtonsCell? = tableView.dequeueAndRegisterCell(indexPath: indexPath)
//
//            cell?.update(with: .init(buttons: ["100%", "75%", "50%", "25%", "10%"]))
//
//            return cell!
//
//        case 5:
//            let cell: StakingTransferDescriptionCell? = tableView.dequeueAndRegisterCell(indexPath: indexPath)
//
////            cell?.update(with: .init(buttons: ["100%", "75%", "50%", "25%", "10%"]))
//
//            let fullText = """
//• The fee is 0. For 100 USD, you'll get exaсtly 100 USDN.
//
//• After a successful payment on the partners' website,
//  USDN will be credited to your account within a few
//  minutes.
//
//• The minimum amount is 10 USDN. The maximum
//  amount is 3,000 USDN.
//
//• If you have problems with your payment, please create
//  a ticket on the support website.
//"""
//
//            let url = URL.init(string: "HTTP://ya.ru")!
//
//            let string = NSMutableAttributedString(string: fullText)
//
//
//            string.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.basic500,
//                                  NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)],
//                                 range: NSRange.init(location: 0,
//                                                     length: string.length))
//
//            string.addAttributes([NSAttributedString.Key.link: url], range: fullText.nsRange(of: "support")!)
//
//            cell?.update(with: string)
//
//            return cell!
//
//        case 6:
//            let cell: StakingTransferFeeInfoCell? = tableView.dequeueAndRegisterCell(indexPath: indexPath)
//
//
//            cell?.update(with: .init(balance: .init(currency: .init(title: "USDN",
//                                                                    ticker: "USDN"),
//                                                    money: .init(10000000,
//                                                                 8))))
//            return cell!
//
//        case 7:
//
//            let cell: StakingTransferButtonCell? = tableView.dequeueAndRegisterCell(indexPath: indexPath)
//
////            cell?.update(with: .init(assetURL: .init(assetId: "WAVES", name: "WAVES", url: nil, isSponsored: false, hasScript: false), title: "Test", money: Money.init(10000000, 100)))
//
//            return cell!
//
//
//        default:
//            let cell: StakingTransferBalanceCell? = tableView.dequeueAndRegisterCell(indexPath: indexPath)
//
//            cell?.update(with: .init(assetURL: .init(assetId: "WAVES", name: "WAVES", url: nil, isSponsored: false, hasScript: false), title: "Test", money: Money.init(10000000, 100)))
//
//            return cell!
//        }
    }
}

extension StakingTransferViewController: UITableViewDelegate {
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell is StakingTransferInputFieldCell {
//            cell.becomeFirstResponder()
        }
//        let item = sections(by: tableView)[indexPath.section].items[indexPath.row]
//        switch item {
//        case .historySkeleton:
//            let skeletonCell: WalletHistorySkeletonCell? = cell as? WalletHistorySkeletonCell
//            skeletonCell?.startAnimation()
//
//        case .assetSkeleton:
//            let skeletonCell: WalletAssetSkeletonCell? = cell as? WalletAssetSkeletonCell
//            skeletonCell?.startAnimation()
//
//        case .balanceSkeleton:
//            let skeletonCell: WalletLeasingBalanceSkeletonCell? = cell as? WalletLeasingBalanceSkeletonCell
//            skeletonCell?.startAnimation()
//        default:
//            break
//        }
    }
}

extension StakingTransferViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        self.modalTableViewController.scrollViewWillEndDragging(scrollView,
                                                                withVelocity: velocity,
                                                                targetContentOffset: targetContentOffset)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.modalTableViewController.scrollViewDidScroll(scrollView)
        
        let yOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        
        if yOffset > scrollView.contentInset.top {
            stakingTransferHeaderView.isHiddenSepatator = false
        } else {
            stakingTransferHeaderView.isHiddenSepatator = true
        }
    }
}

