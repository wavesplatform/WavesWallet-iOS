//
//  ModalScrollViewController.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 01/02/2019.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import Foundation
import UIKit
import WavesSDKExtensions

private struct Constants {
    static let offsetDistanceForDismiss: CGFloat = 48
    static let velocityForDismiss: CGFloat = 0.95
}

class ModalScrollViewController: UIViewController, ModalScrollViewContext {

    private var needUpdateInsets: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()        
        self.scrollView.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if needUpdateInsets {
            needUpdateInsets = false
            setNeedUpdateInset(animated: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupScrollView()
                
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        needUpdateInsets = true
    }

    // MARK: Need overriding
    var scrollView: UIScrollView {
        assertMethodNeedOverriding()
        return UIScrollView()
    }

    // MARK: Need overriding
    func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        assertMethodNeedOverriding()
        return 0.0
    }

    // MARK: Need overriding
    func bottomScrollInset(for size: CGSize) -> CGFloat {
        return 0.0
    }
}

// MARK: Setup methods

extension ModalScrollViewController  {

    private func setNeedUpdateInset(animated: Bool = false) {
        
        setupInsets(animated: animated)
//        view.layoutIfNeeded()
    }

    private func setupInsets(animated: Bool) {
//
//        print("View \(self.view.frame.size)")
//        print("scrollView \(self.scrollView.frame.size)")
//        print("self.layoutInsets \(self.layoutInsets)")
//        print("adjustedContentInset \(self.scrollView.adjustedContentInset)")
//        print("visibleScrollViewHeight \(visibleScrollViewHeight(for: scrollView.frame.size))")
         
        let bottom = bottomScrollInset(for: scrollView.frame.size)
        let top = scrollView.frame.height - visibleScrollViewHeight(for: scrollView.frame.size)
                
//        print("top \(top)")
        
        let contentOffset = top
        scrollView.contentInset.bottom = bottom
        scrollView.contentInset.top = top
        scrollView.scrollIndicatorInsets.top = contentOffset
                
        var content = scrollView.contentOffset
        content.y = -(contentOffset)
        scrollView.setContentOffset(content, animated: animated)
        scrollView.scrollIndicatorInsets.top = max(0, -(scrollView.contentOffset.y))
        
//        print("adjustedContentInset before \(self.scrollView.adjustedContentInset)")
//        print("contentInset before \(self.scrollView.contentInset)")
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

extension ModalScrollViewController: ModalPresentationAnimatorContext {

    func hideBoundaries(for size: CGSize) -> CGRect {

        return CGRect(x: 0,
                      y: 0,
                      width: size.width,
                      height: self.layoutInsets.top + scrollView.contentInset.top - (scrollView.contentOffset.y + scrollView.contentInset.top))
    }

    func appearingContentHeight(for size:  CGSize) -> CGFloat {
        return 0
    }

    func disappearingContentHeight(for size:  CGSize) -> CGFloat {

        if scrollView.contentOffset.y < 0 {
            return scrollView.bounds.height + scrollView.contentOffset.y + scrollView.contentInset.top
        } else {
            return scrollView.bounds.height
        }
    }

    func contentHeight(for size: CGSize) -> CGFloat {
        return size.height
    }
}

extension ModalScrollViewController: UIScrollViewDelegate {

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {

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

        //TODO: Check speed
        setupScrollView()
    }
}
