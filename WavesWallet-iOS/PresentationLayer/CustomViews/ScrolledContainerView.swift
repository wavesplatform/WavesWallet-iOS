//
//  CustomView.swift
//  testApp
//
//  Created by Pavel Gubin on 5/13/19.
//  Copyright © 2019 Pavel Gubin. All rights reserved.
//

#warning("bug with segmendtedControl position on swipe when refresh is animating")
#warning("Прыгающий navigation bar (при переходе на маленький navBar и обратно)")
#warning("Установка view после инициализации")

import UIKit

private enum Constants {
    static let animationDuration: TimeInterval = 0.3
    static let segmentedHeight: CGFloat = 40
    static let bigNavBarHeight: CGFloat = 96
    static let smallNavBarHeight: CGFloat = 44
    static let refreshSize: CGFloat = 30
}

protocol ContainerViewDelegate: AnyObject {
    func containerViewDidRemoveView(_ view: UIView)
}

class ContainerView: UIView {
    weak var delegate: ContainerViewDelegate?
}

protocol ScrolledContainerViewProtocol {
    
    func setup(segmentedItems: [String], topContents:[UIView], topContentsSectionIndex: Int, tableDataSource: UITableViewDataSource, tableDelegate: UITableViewDelegate)
    
    func removeView(_ view: UIView, animation: Bool)
    
    func reloadData()
    
    func viewControllerWillDissapear()
    
    var segmentedHeight: CGFloat { get }
    
    var visibleTableView: UITableView { get }
    
    var smallTopOffset: CGFloat { get }
    
}

@objc protocol ScrolledContainerViewDelegate: AnyObject {
    func scrolledContainerViewDidScrollToIndex(_ index: Int)
}

final class ScrolledContainerView: UIScrollView {
    
    private(set) var tableViews: [UITableView] = []
    private var topContents: [UIView] = []
    private(set) var segmentedControl = NewSegmentedControl()
    
    private var currentIndex: Int = 0
    private var isAnimationTable: Bool = false
    private var topContentsSectionIndex: Int = 0
    private(set) var topOffset: CGFloat = 0

    weak var scrollViewDelegate: UIScrollViewDelegate?
    weak var containerViewDelegate: ScrolledContainerViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        
        showsHorizontalScrollIndicator = false
        contentInsetAdjustmentBehavior = .automatic
        insetsLayoutMarginsFromSafeArea = true
        
        let leftRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handlerLeftSwipe(_:)))
        leftRightGesture.direction = .left
        addGestureRecognizer(leftRightGesture)
        
        let rightRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handlerRightSwipe(_:)))
        rightRightGesture.direction = .right
        addGestureRecognizer(rightRightGesture)
        alwaysBounceVertical = true
        backgroundColor = .clear
        
        refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 0, width: Constants.refreshSize, height: Constants.refreshSize))
        segmentedControl.segmentedDelegate = self
    }
  
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if visibleTableView.frame.size.height != frame.size.height ||
            visibleTableView.frame.size.width != frame.size.width {
            for table in tableViews {
                table.frame.size.height = frame.size.height
                table.frame.size.width = frame.size.width
            }
        }
        
        if segmentedControl.frame.size.width != frame.size.width {
            segmentedControl.frame.size.width = frame.size.width
        }
        
        for view in topContents {
            if view.frame.size.width != frame.size.width {
                view.frame.size.width = frame.size.width
            }
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        segmentedControl.frame = .init(x: 0, y: topSegmentOffset, width: frame.size.width, height: Constants.segmentedHeight)
        segmentedControl.backgroundColor = UIColor.init(red: 248/255, green: 249/255, blue: 251/255, alpha: 1)
        superview?.addSubview(segmentedControl)
    }
}

//MARK: - ScrolledContainerViewProtocol
extension ScrolledContainerView: ScrolledContainerViewProtocol {
   
    func viewControllerWillDissapear() {
        if isSmallNavBar {
            firstAvailableViewController().setupSmallNavigationBar()
        }
        else {
            firstAvailableViewController().setupBigNavigationBar()
        }
    }
    
    
    func setup(segmentedItems: [String], topContents:[UIView], topContentsSectionIndex: Int, tableDataSource: UITableViewDataSource, tableDelegate: UITableViewDelegate) {
        
        self.segmentedControl.items = segmentedItems
        self.topContentsSectionIndex = topContentsSectionIndex
        self.topContents = topContents

        for view in topContents {
            view.frame.origin.y = topOffset
            addSubview(view)
            topOffset += view.frame.size.height
        }
        
        for index in 0..<segmentedItems.count {
            
            let table = UITableView(frame: CGRect(x: CGFloat(index) * frame.size.width,
                                                  y: 0,
                                                  width: frame.size.width,
                                                  height: frame.size.height))
            table.tag = index
            table.dataSource = tableDataSource
            table.delegate = tableDelegate
            table.separatorStyle = .none
            table.isScrollEnabled = false
            table.backgroundColor = .clear
            addSubview(table)
            tableViews.append(table)
        }
        
        for view in self.topContents {
            bringSubviewToFront(view)
        }
        
        visibleTableView.reloadData()
        setContentSize()
    }
    
    func removeView(_ view: UIView, animation: Bool) {
        
        if let index = topContents.firstIndex(of: view) {
            let indexPath = IndexPath(row: index, section: topContentsSectionIndex)
            
            topContents.removeAll(where: {$0 == view})
            
            for table in tableViews {
                if table == visibleTableView && animation {
                    table.beginUpdates()
                    table.deleteRows(at: [indexPath], with: .fade)
                    table.endUpdates()
                }
                else {
                    table.reloadData()
                }
            }
        }
        
        topOffset = 0
        
        let table = visibleTableView
        UIView.animate(withDuration: animation ? Constants.animationDuration : 0, animations: {
            
            for view in self.topContents {
                view.frame.origin.y = self.topOffset
                self.topOffset += view.frame.size.height
            }
            
            view.alpha = 0
            self.contentOffset.y -= view.frame.size.height
            if self.contentOffset.y > 0 {
                table.frame.origin.y = self.contentOffset.y
                table.contentOffset.y = self.contentOffset.y
            }
            else {
                table.frame.origin.y = 0
                table.contentOffset.y = 0
            }
            
        }) { (complete) in
            view.removeFromSuperview()
        }
    }
    
    func reloadData() {
        for table in tableViews {
            table.reloadData()
        }
    }
    
    var segmentedHeight: CGFloat {
        return Constants.segmentedHeight
    }
    
    var visibleTableView: UITableView {
        return tableViews.first(where: {$0.tag == currentIndex})!
    }
    
    var smallTopOffset: CGFloat {
        return Constants.smallNavBarHeight + navigationBarOriginY
    }
}

//MARK: - Actions
private extension ScrolledContainerView {
    
    @objc func handlerRightSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            showPrevScreen(prevIndex: currentIndex - 1)
            segmentedControl.setSelectedIndex(currentIndex, animation: true)
        }
    }
    
    @objc func handlerLeftSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            showNextScreen(nextIndex: currentIndex + 1)
            segmentedControl.setSelectedIndex(currentIndex, animation: true)
        }
    }
}

//MARK: - UIScrollViewDelegate
extension ScrolledContainerView: UIScrollViewDelegate {
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        segmentedControl.frame.origin.y = topSegmentOffset

        if isAnimationTable {
            return
        }
        
        if scrollView.contentOffset.y < -smallTopOffset {
            firstAvailableViewController().setupBigNavigationBar()
        }
        
        let table = visibleTableView
        if scrollView.contentOffset.y > 0 {
            table.frame.origin.y = scrollView.contentOffset.y
            table.contentOffset.y = scrollView.contentOffset.y
        }
        else {
            table.frame.origin.y = 0
            table.contentOffset.y = 0
        }
        
        if contentSize.height != table.contentSize.height {
            contentSize.height = table.contentSize.height
        }
        
        updateSegmentedShadow()
        
        scrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }
}

//MARK: - SegmentedControlDelegate
extension ScrolledContainerView: NewSegmentedControlDelegate {

    func segmentedControlDidChangeIndex(_ index: Int) {
        if index > currentIndex {
            showNextScreen(nextIndex: index)
        }
        else {
            showPrevScreen(prevIndex: index)
        }
    }
}


private extension ScrolledContainerView {
  
    func setContentSize() {
        contentSize = CGSize(width: contentSize.width, height: visibleTableView.contentSize.height)
    }
    
    func acceptCurrentTableOffset() -> UITableView {
        isAnimationTable = true
        let lastOffset = contentOffset.y
        
        if isSmallNavBar {
            firstAvailableViewController().setupSmallNavigationBar()
            if contentOffset.y >= topOffset - smallTopOffset {
                contentOffset.y = topOffset - smallTopOffset
            }
        }
        
        let newOffset = contentOffset.y - lastOffset
        let currentTable = visibleTableView
        currentTable.frame.origin.y += newOffset
        return currentTable
    }
    
    func updateNewTableOffset(_ newTable: UITableView) {
        newTable.frame.origin.y = contentOffset.y > 0 ? contentOffset.y : 0
        newTable.contentOffset.y = contentOffset.y > 0 ? contentOffset.y : 0
        
        if newTable.frame.origin.y + newTable.frame.size.height > contentSize.height &&
            contentSize.height > self.frame.size.height {
            newTable.frame.origin.y = contentSize.height - newTable.frame.size.height
        }
    }
    
    func showNextScreen(nextIndex: Int) {
        
        if nextIndex < segmentedControl.items.count {
            
            containerViewDelegate?.scrolledContainerViewDidScrollToIndex(nextIndex)
            
            let currentTable = acceptCurrentTableOffset()
            currentIndex = nextIndex
            
            UIView.animate(withDuration: Constants.animationDuration) {
                self.setContentSize()
                self.segmentedControl.frame.origin.y = self.topSegmentOffset
            }
            
            updateSegmentedShadow()
            let newTable = visibleTableView
            newTable.frame.origin.x = frame.size.width
            updateNewTableOffset(newTable)

            updateSwipeAnimationBlock {
                newTable.frame.origin.x = 0
                currentTable.frame.origin.x = -self.frame.size.width
            }
        }
    }
    
    func showPrevScreen(prevIndex: Int) {

        if prevIndex >= 0 {
            
            containerViewDelegate?.scrolledContainerViewDidScrollToIndex(prevIndex)
            
            let currentTable = acceptCurrentTableOffset()
            currentIndex = prevIndex
            
            UIView.animate(withDuration: Constants.animationDuration) {
                self.setContentSize()
                self.segmentedControl.frame.origin.y = self.topSegmentOffset
            }
            
            updateSegmentedShadow()
            let newTable = visibleTableView
            newTable.frame.origin.x = -frame.size.width
            updateNewTableOffset(newTable)
            
            updateSwipeAnimationBlock {
                newTable.frame.origin.x = 0
                currentTable.frame.origin.x = self.frame.size.width
            }
        }
    }
    
    func updateSwipeAnimationBlock(_ block:@escaping() -> Void) {
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            block()
        }) { (complete) in
            self.isAnimationTable = false
        }
    }
    
    func updateSegmentedShadow() {
        if topOffset - contentOffset.y <= smallTopOffset {
            segmentedControl.addShadow()
        }
        else {
            segmentedControl.removeShadow()
        }
    }
    
    var topSegmentOffset: CGFloat {
        var offset = -contentOffset.y + topOffset
        if offset < smallTopOffset {
            offset = smallTopOffset
        }
        return offset
    }
    
    var navigationBarOriginY: CGFloat {
        return firstAvailableViewController().navigationController?.navigationBar.frame.origin.y ?? 0
    }
    
    var bigTopOffset: CGFloat {
        return Constants.bigNavBarHeight + navigationBarOriginY
    }
    
    var isSmallNavBar: Bool {
        if let nav = firstAvailableViewController().navigationController {
            return nav.navigationBar.frame.size.height.rounded(.down) <= Constants.smallNavBarHeight
        }
        return false
    }
}
