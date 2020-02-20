//
//  File.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

final class ModalTableViewController: ModalScrollViewController, NibReusable {
            
    @IBOutlet var tableView: ModalTableView!
    
    weak var delegate: ModalTableControllerDelegate? {
        didSet {
            if isViewLoaded {
                setupDataSources()
            }
        }
    }
     
    override var scrollView: UIScrollView {
        return tableView
    }
    
    private var rootView: ModalRootView {
        return view as! ModalRootView
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSources()
    }
                    
    override func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        return delegate?.visibleScrollViewHeight(for: size) ?? size.height
    }
    
    override func bottomScrollInset(for size: CGSize) -> CGFloat {
        return delegate?.bottomScrollInset(for: size) ?? 0
    }
    
    static func create() -> ModalTableViewController {
        return ModalTableViewController.loadFromNib()
    }
    
}

// MARK: Private

private extension ModalTableViewController {
    
    func setupDataSources() {
        self.tableView.delegate = self.delegate?.tableDelegate
        self.tableView.dataSource = self.delegate?.tableDataSource
    }
}

// MARK: ModalRootViewDelegate

extension ModalTableViewController: ModalRootViewDelegate {
    
    func modalHeaderView() -> UIView {
        return delegate?.modalHeaderView() ?? UIView()
    }
    
    func modalHeaderHeight() -> CGFloat {
        return delegate?.modalHeaderHeight() ?? 0
    }
}
