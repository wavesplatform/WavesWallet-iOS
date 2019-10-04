//
//  EditAccountNameViewController.swift
//  WavesWallet-iOS
//
//  Created by Лера on 10/3/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import DomainLayer
import IdentityImg
import Extensions

private struct Constants {
    static let headerViewHeight: CGFloat = 20
    static let iconSize = CGSize(width: 28, height: 28)
    static let height: CGFloat = 455 + (Platform.isSupportFaceID ? 70 : 0)
}

final class NewEditAccountNameViewController: ModalScrollViewController {

    private let headerView: TransactionCardHeaderView = TransactionCardHeaderView.loadView() as! TransactionCardHeaderView
    
    override var scrollView: UIScrollView {
        return tableView
    }
    
    override func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        return Constants.height
    }
    
    private var rootView: ModalRootView {
        return view as! ModalRootView
    }
    
    @IBOutlet private weak var tableView: ModalTableView!
    
    private var newName: String = ""
    private let identity: Identity = Identity(options: Identity.defaultOptions)

    var wallet: DomainLayer.DTO.Wallet!
    weak var delegate: NewEditAccountNameModuleBuilderOutput?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        headerView.isHiddenSepatator = true
        rootView.delegate = self
        newName = wallet.name
    }
}

//MARK: - UITableViewDataSource
extension NewEditAccountNameViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell() as NewEditAccountNameCell
        cell.delegate = self
        cell.update(with: .init(oldName: wallet.name,
                                newName: newName,
                                icon: identity.createImage(by: wallet.address, size: Constants.iconSize)))
        return cell
    }
}

//MARK: - NewEditAccountNameCellDelegate
extension NewEditAccountNameViewController: NewEditAccountNameCellDelegate {
    
    func newEditAccountNameDidChangeName(newName: String) {
        self.newName = newName
    }
    
    func newEditAccountNameDidTapSave() {
        delegate?.newEditAccountDidChangeName(newName: newName)
    }
}

// MARK: ModalRootViewDelegate
extension NewEditAccountNameViewController: ModalRootViewDelegate {
    
    func modalHeaderView() -> UIView {
        return headerView
    }
    
    func modalHeaderHeight() -> CGFloat {
        return Constants.headerViewHeight
    }
}

