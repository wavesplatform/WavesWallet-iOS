//
//  CustomView.swift
//  testApp
//
//  Created by Pavel Gubin on 5/13/19.
//  Copyright © 2019 Pavel Gubin. All rights reserved.
//

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
    
    func setup(segmentedItems: [String], tableDataSource: UITableViewDataSource, tableDelegate: UITableViewDelegate)
    
    func removeTopView(_ view: UIView, animation: Bool)
    
    func addTopView(_ view: UIView, animation: Bool)
    
    func reloadData()
    
    func viewControllerWillDissapear()
    
    func viewControllerWillAppear()
    
    func setContentSize()
    
    func scrollToTop()
    
    func endRefreshing()
    
    func reloadSectionWithCloseAnimation(section: Int)
    
    func reloadSectionWithOpenAnimation(section: Int)
    
    var segmentedHeight: CGFloat { get }
    
    var visibleTableView: UITableView { get }
    
    var smallTopOffset: CGFloat { get }
}

@objc protocol ScrolledContainerViewDelegate: AnyObject {
    func scrolledContainerViewDidScrollToIndex(_ index: Int)
}

final class ScrolledContainerView: UIScrollView {
    
    private(set) var tableViews: [UITableView] = []
    private(set) var topContents: [UIView] = []
    private(set) var segmentedControl = NewSegmentedControl()
    
    private var currentIndex: Int = 0
    private var isAnimationTable: Bool = false
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackgroundHandler), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc private func didEnterBackgroundHandler() {
        if isSmallNavBar {
            firstAvailableViewController().setupSmallNavigationBar()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if visibleTableView.frame.size.height != frame.size.height + topOffset ||
            visibleTableView.frame.size.width != frame.size.width {
            for (index, table) in tableViews.enumerated() {
                table.frame.origin.x = CGFloat(index) * frame.size.width
                table.frame.size.height = frame.size.height + topOffset
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
}

//MARK: - ScrolledContainerViewProtocol
extension ScrolledContainerView: ScrolledContainerViewProtocol {
    
    func reloadSectionWithOpenAnimation(section: Int) {
        visibleTableView.beginUpdates()
        visibleTableView.reloadSections([section], with: .fade)
        visibleTableView.endUpdates()
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: Constants.animationDuration, animations: {
                self.setContentSize()
            })
            
            guard self.visibleTableView.numberOfRows(inSection: section) > 0 else { return }
            
            let indexPath = IndexPath(row: 0, section: section)
            let rectInTableView = self.visibleTableView.rectForRow(at: indexPath)
            let rectInSuperview = self.visibleTableView.convert(rectInTableView, to: self)
            
            var offset = self.contentOffset.y
            
            if rectInSuperview.origin.y - self.bigTopOffset > self.frame.size.height / 2 {
                offset += self.frame.size.height / 2 - self.bigTopOffset
                if offset > self.contentSize.height - self.frame.size.height {
                    offset = self.contentSize.height - self.frame.size.height
                }
                
                if self.isSmallNavBar || offset > -self.smallTopOffset {
                    self.firstAvailableViewController().setupSmallNavigationBar()
                }
                self.setContentOffset(.init(x: 0, y: offset), animated: true)
                self.scrollViewDidScroll(self)
                
            }
        }
        
    }
    
    func reloadSectionWithCloseAnimation(section: Int) {
        
        let offset = visibleTableView.contentOffset.y
        visibleTableView.beginUpdates()
        visibleTableView.reloadSections([section], with: .fade)
        visibleTableView.endUpdates()
        
        DispatchQueue.main.async {
            let diff = self.visibleTableView.contentOffset.y - offset
            let isSmallNavBarBefore = self.isSmallNavBar
            
            if diff == 0 {
                UIView.animate(withDuration: Constants.animationDuration, animations: {
                    self.setContentSize()
                })
            }
            else {
                let newOffset = self.contentOffset.y + diff
                self.setContentOffset(.init(x: 0, y: newOffset), animated: false)
                self.scrollViewDidScroll(self)
            }
            
            if isSmallNavBarBefore {
                self.firstAvailableViewController().setupSmallNavigationBar()
            }
        }
    }
    
    
    func viewControllerWillAppear() {
        if refreshControl?.isRefreshing == true {
            DispatchQueue.main.async {
                self.endRefreshing()
                self.scrollViewDidScroll(self)
            }
        }
    }
    
    func endRefreshing() {
        
        if refreshControl?.isRefreshing == true {
            if isSmallNavBar {
                firstAvailableViewController().setupSmallNavigationBar()
            }
            refreshControl?.endRefreshing()
        }
    }
    
    func viewControllerWillDissapear() {
        if isSmallNavBar {
            firstAvailableViewController().setupSmallNavigationBar()
        }
        else {
            firstAvailableViewController().setupBigNavigationBar()
        }
        
    }
    
    func setup(segmentedItems: [String], tableDataSource: UITableViewDataSource, tableDelegate: UITableViewDelegate) {
        
        self.segmentedControl.items = segmentedItems
        
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
            table.contentInset.top = segmentedHeight
            addSubview(table)
            tableViews.append(table)
        }
        
        segmentedControl.frame = .init(x: 0, y: topSegmentOffset, width: frame.size.width, height: Constants.segmentedHeight)
        segmentedControl.backgroundColor = .basic50
        addSubview(segmentedControl)
        
        visibleTableView.reloadData()
        setContentSize()
    }
    
    func removeTopView(_ view: UIView, animation: Bool) {
        
        topContents.removeAll(where: {$0 == view})
        topOffset = topContents.map {$0.frame.size.height}.reduce(0, {$0 + $1})
        
        UIView.animate(withDuration: animation ? Constants.animationDuration : 0, animations: {
            view.alpha = 0
            
            var offset: CGFloat = 0
            for topView in self.topContents {
                topView.frame.origin.y = offset
                offset += topView.frame.size.height
            }
            
            for table in self.tableViews {
                table.contentInset.top = self.topOffset + self.segmentedHeight
            }
            
            self.scrollViewDidScroll(self)
        }) { (complete) in
            view.removeFromSuperview()
        }
    }
    
    func addTopView(_ view: UIView, animation: Bool) {
        
        topContents.append(view)
        addSubview(view)
        layoutIfNeeded()
        
        view.alpha = 0
        
        topOffset = 0
        for topView in self.topContents {
            topView.frame.origin.y = topOffset
            topOffset += topView.frame.size.height
        }
        
        UIView.animate(withDuration: animation ? Constants.animationDuration : 0, animations: {
            view.alpha = 1
            
            for table in self.tableViews {
                table.contentInset.top = self.topOffset + self.segmentedHeight
            }
            
            self.scrollViewDidScroll(self)
        })
    }
    
    func reloadData() {
        
        layoutIfNeeded()
        
        topOffset = 0
        for view in topContents {
            view.frame.origin.y = topOffset
            topOffset += view.frame.size.height
        }
        
        for table in tableViews {
            table.reloadData()
            table.contentInset.top = topOffset + segmentedHeight
        }
        
        setContentSize()
        DispatchQueue.main.async {
            self.scrollViewDidScroll(self)
        }
    }
    
    func scrollToTop() {
        var offset = -bigTopOffset
        if refreshControl?.isRefreshing == true {
            offset -= refreshControl?.frame.size.height ?? 0
        }
        setContentOffset(.init(x: 0, y: offset), animated: true)
    }
    
    func setContentSize() {
        contentSize = CGSize(width: contentSize.width, height: visibleContentHeight)
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
        
        setupSegmentedPosition()
        if isAnimationTable {
            return
        }
        
        if scrollView.contentOffset.y < -smallTopOffset {
            firstAvailableViewController().setupBigNavigationBar()
        }
        
        let table = visibleTableView
        table.frame.origin.y = tableTopPosition
        table.contentOffset.y = tableTopPosition - table.contentInset.top
        
        if contentSize.height != visibleContentHeight {
            contentSize.height = visibleContentHeight
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
    
    func setupSegmentedPosition() {
        segmentedControl.frame.origin.y = topSegmentOffset
    }
    
    func acceptCurrentTableOffset() -> UITableView {
        isAnimationTable = true
        
        var diff: CGFloat = 0
        let currentTable = visibleTableView
        
        let offset = contentSize.height - currentTable.frame.origin.y - currentTable.frame.size.height
        
        if contentSize.height < currentTable.frame.size.height {
            diff = -(contentOffset.y + smallTopOffset) + topOffset
        }
        else {
            diff = offset
        }
        
        diff = min(diff, 0)
        
        if isSmallNavBar {
            firstAvailableViewController().setupSmallNavigationBar()
            if contentOffset.y >= topOffset - smallTopOffset {
                contentOffset.y = topOffset - smallTopOffset
            }
        }
        
        currentTable.frame.origin.y = diff
        return currentTable
    }
    
    
    func updateNewTableOffset(_ newTable: UITableView) {
        
        newTable.frame.origin.y = tableTopPosition
        newTable.contentOffset.y = tableTopPosition - newTable.contentInset.top
        
        if newTable.frame.origin.y + newTable.frame.size.height > contentSize.height &&
            contentSize.height > newTable.frame.size.height {
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
                self.setupSegmentedPosition()
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
                self.setupSegmentedPosition()
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
    
    var visibleContentHeight: CGFloat {
        return visibleTableView.contentSize.height + visibleTableView.contentInset.top
    }
    
    var topSegmentOffset: CGFloat {
        
        if contentOffset.y > -smallTopOffset + topOffset {
            return contentOffset.y + smallTopOffset
        }
        return topOffset
    }
    
    var navigationBarOriginY: CGFloat {
        return firstAvailableViewController().navigationController?.navigationBar.frame.origin.y ?? 0
    }
    
    var navigationBarHeight: CGFloat {
        return firstAvailableViewController().navigationController?.navigationBar.frame.size.height ?? 0
    }
    
    var isSmallNavBar: Bool {
        return firstAvailableViewController().isSmallNavigationBar
    }
    
    var bigTopOffset: CGFloat {
        return Constants.bigNavBarHeight + navigationBarOriginY
    }
    
    var tableTopPosition: CGFloat {
        let navBarSize = navigationBarOriginY + navigationBarHeight
        var topOffset = navBarSize + contentOffset.y
        topOffset -= self.topOffset
        return topOffset > 0 ? topOffset : 0
    }
}
