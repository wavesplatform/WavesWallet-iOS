//
//  WidgetSettingsIntervalViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 01.08.2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import UIKit

private enum Constants {
    static let headerHeight: CGFloat = 74
    static let cellHeight: CGFloat = 64
    static let bottomInset: CGFloat = 16
}

final class ActionSheetViewController: ModalScrollViewController {
    
    @IBOutlet var tableView: ModalTableView!
    
    override var scrollView: UIScrollView {
        return tableView
    }
    
    private var rootView: ModalRootView {
        return view as! ModalRootView
    }
    
    private var headerView: ActionSheetHeaderView = ActionSheetHeaderView.loadView()
    
    var data: ActionSheet.DTO.Data! {
        
        didSet {
            if let selectedElement = data.selectedElement {
                selectedElementsMap[selectedElement.title] = selectedElement
            }
            headerView.update(with: .init(title: data.title))
            tableView?.reloadData()
        }
    }
    
    private var selectedElementsMap: [String: ActionSheet.DTO.Element] = .init()
    
    var elementDidSelect: ((ActionSheet.DTO.Element) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.delegate = self
    }
    
    override func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        
        let height = CGFloat((data?.elements.count ?? 0)) * Constants.cellHeight + Constants.headerHeight
        return min(height, size.height * 0.5)
    }
    
    override func bottomScrollInset(for size: CGSize) -> CGFloat {
        return Constants.bottomInset
    }
}

// MARK: ModalRootViewDelegate

extension ActionSheetViewController: ModalRootViewDelegate {
    
    func modalHeaderView() -> UIView {
        return headerView
    }
    
    func modalHeaderHeight() -> CGFloat {
        return Constants.headerHeight
    }
}

// MARK: UITableViewDataSource

extension ActionSheetViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                        
        let cell: ActionSheetElementCell = tableView.dequeueCell()
        
        let element = data.elements[indexPath.row]
        
        cell.update(with: .init(title: element.title, isSelected: selectedElementsMap[element.title] != nil))
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.elements.count ?? 0
    }
}

// MARK: UITableViewDelegate

extension ActionSheetViewController: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let element = data.elements [indexPath.row]
        elementDidSelect?(element)
        
        
        selectedElementsMap.removeAll()
        selectedElementsMap[element.title] = element
        tableView.reloadData()
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
