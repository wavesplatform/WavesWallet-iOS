//
//  ModalScrollViewController.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 01/02/2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
import WavesSDKExtension

private struct Constants {
    static let offsetDistanceForDismiss: CGFloat = 48
    static let velocityForDismiss: CGFloat = 0.95
}

protocol ModalScrollViewContext {

    var scrollView: UIScrollView { get }

    func visibleScrollViewHeight(for size: CGSize) -> CGFloat
}

protocol ModalScrollViewRootView: AnyObject {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

class ModalScrollViewController: UIViewController {

    private var needUpdateInsets: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()        
        self.scrollView.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setNeedUpdateInset()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupScrollView()        
        needUpdateInsets = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    //MARK: Need overriding
    var scrollView: UIScrollView {
        assertMethodNeedOverriding()
        return UIScrollView()
    }

    //MARK: Need overriding
    func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        assertMethodNeedOverriding()
        return 0.0
    }

    func bottomScrollInset(for size: CGSize) -> CGFloat {
        return 0.0
    }
}

// MARK: Setup methods

extension ModalScrollViewController  {

    private func setNeedUpdateInset() {
        if needUpdateInsets {
            setupInsets()
            view.layoutIfNeeded()
        }
    }

    private func setupInsets() {

        let top = scrollView.frame.height - visibleScrollViewHeight(for: scrollView.frame.size)
        scrollView.contentInset.bottom = bottomScrollInset(for: scrollView.frame.size)
        scrollView.contentInset.top = top
        scrollView.scrollIndicatorInsets.top = top
        scrollView.contentOffset.y = -top
    }

    private func setupScrollView() {

        var currentView: UIView? = scrollView

        repeat {            
            currentView?.shouldPassthroughTouch = true
            currentView?.isEnabledPassthroughSubviews = true
            currentView = currentView?.superview
        } while currentView != view.superview
    }
}

extension ModalScrollViewController: ModalScrollViewContext {

    func appearingContentHeight(for size:  CGSize) -> CGFloat {
        return 0
    }

    func disappearingContentHeight(for size:  CGSize) -> CGFloat {

        if scrollView.contentOffset.y < 0 {
            return scrollView.bounds.height + scrollView.contentOffset.y
        } else {
            return scrollView.bounds.height
        }
    }

    func contentHeight(for size: CGSize) -> CGFloat {
        return size.height
    }
}

extension ModalScrollViewController: UIScrollViewDelegate {

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let dismissBlock = {
            targetContentOffset.pointee = scrollView.contentOffset
            self.dismiss(animated: true)
        }

        let velocity = abs(min(0, velocity.y))

        let distanceForDismiss = visibleScrollViewHeight(for: scrollView.bounds.size) - Constants.offsetDistanceForDismiss
        let distanceFromBottomEdge = scrollView.bounds.height + scrollView.contentOffset.y

        if velocity > Constants.velocityForDismiss && distanceFromBottomEdge < distanceForDismiss {
            dismissBlock()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        //it`s code need for ModalRootView
        if let view = self.view as? ModalScrollViewRootView {
            view.scrollViewDidScroll(scrollView)
        }
    }
}
