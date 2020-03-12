//
//  TooltipViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 11.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//
import UIKit
import Extensions

private enum Constants {
    static let headerHeight: CGFloat = 70
    static let contentHeight: CGFloat = 440
}

protocol TooltipViewControllerModulInput {
    var data: TooltipTypes.DTO.Data { get }
}

protocol TooltipViewControllerModulOutput: AnyObject {
    func tooltipDidTapClose()
}

final class TooltipViewController: ModalScrollViewController {
        
    @IBOutlet var tableView: ModalTableView!
    
    override var scrollView: UIScrollView {
        return tableView
    }
    
    private var rootView: ModalRootView {
        return view as! ModalRootView
    }
        
    private let headerView:TooltipHeaderView = TooltipHeaderView.loadView()
    private var rows: [TooltipTypes.ViewModel.Row] = .init()
    
    weak var moduleOutput: TooltipViewControllerModulOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rootView.delegate = self
        tableView.reloadData()
    }
    
    // TODO: Нужно сделать динамическую высоту
    override func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        return Constants.contentHeight
    }
    
    override func bottomScrollInset(for size: CGSize) -> CGFloat {
        return 0.0
    }
}

// MARK: ViewConfiguration

extension TooltipViewController: ViewConfiguration {
    
    func update(with model: TooltipViewControllerModulInput) {
        let elements = model.data.elements.map { TooltipInfoCell.Model.init(title: $0.title,
                                                                        description: $0.description) }
        
        var rows: [TooltipTypes.ViewModel.Row]  = .init()
        
        elements.enumerated().forEach { index, element in
            let isLastElement = index == max(elements.count - 1, 0)
            rows.append(.element(element))
                        
            if isLastElement == false {
                rows.append(.separator)
            }
        }
        
        rows.append(.button)
        self.rows = rows
        
        self.headerView.update(with: .init(title: model.data.title))
        
        if isViewLoaded {
            tableView.reloadData()
        }
    }
}

// MARK: ModalRootViewDelegate

extension TooltipViewController: ModalRootViewDelegate {
    
    func modalHeaderView() -> UIView {
        return headerView
    }

    func modalHeaderHeight() -> CGFloat {
        return Constants.headerHeight
    }
}

// MARK: UITableViewDataSource

extension TooltipViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                        
        let row = rows[indexPath.row]
        
        switch row {
        case .element(let model):
            let cell: TooltipInfoCell = tableView.dequeueCell()
            cell.update(with: model)
            return cell
            
        case .button:
            let cell: TooltipButtonCell = tableView.dequeueCell()
            cell.didTap = { [weak self] in
                self?.moduleOutput?.tooltipDidTapClose()
            }
            return cell
            
        case .separator:
            let cell: TooltipSeparatorCell = tableView.dequeueCell()
            return cell            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
}

// MARK: UITableViewDelegate

extension TooltipViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)

        let yOffset = scrollView.contentOffset.y + scrollView.contentInset.top

        if yOffset > scrollView.contentInset.top {
            headerView.isHiddenSepatator = false
        } else {
            headerView.isHiddenSepatator = true
        }
    }
}
