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

final class StakingTransferViewController: UIViewController, ModalTableControllerDelegate {
        
    private var modalTableViewController: ModalTableViewController = ModalTableViewController.create()
    
    weak var tableDataSource: UITableViewDataSource? {
        return self
    }
    
    weak var tableDelegate: UITableViewDelegate? {
        return self
    }
    
    private let disposeBag: DisposeBag = DisposeBag()
           
    private var stakingTransferSystem: System<StakingTransfer.State, StakingTransfer.Event>! = StakingTransferSystem()
    
    private var sections: [Types.ViewModel.Section] = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViewController(viewController: modalTableViewController, rootView: view)
        modalTableViewController.delegate = self
        
        stakingTransferSystem
            .start()
            .drive(onNext: { [weak self] (state) in
                guard let self = self else { return }
                self.update(state: state.core)
                self.update(state: state.ui)
            })
            .disposed(by: disposeBag)
        
    }
}

extension StakingTransferViewController {

    private func update(state: Types.State.Core) {
        
    }
    
    private func update(state: Types.State.UI) {
        
    }
}
    
extension StakingTransferViewController {
    
    func modalHeaderView() -> UIView {
        return UIView()
    }

    func modalHeaderHeight() -> CGFloat {
        return 0
    }
    
    func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        return size.height
    }
    
    func bottomScrollInset(for size: CGSize) -> CGFloat {
        return 0
    }
}

extension StakingTransferViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: StakingTransferBalanceCell? = tableView.dequeueAndRegisterCell(indexPath: indexPath)
        
        return cell!
    }
}

extension StakingTransferViewController: UITableViewDelegate {
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
