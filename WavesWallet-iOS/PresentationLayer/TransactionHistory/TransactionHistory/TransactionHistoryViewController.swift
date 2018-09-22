//
//  TransactionHistoryViewController.swift
//  WavesWallet-iOS
//
//  Created by Mac on 22/08/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import SwipeView
import RxCocoa
import RxFeedback
import RxSwift

private enum Constants {
    static let backgroundAlpha: CGFloat = 0.2
}

class TransactionHistoryViewController: UIViewController {
    
    fileprivate var collectionViewOffset: CGPoint = .zero
    fileprivate var panningEnabled: Bool = false
    fileprivate var presenting: Bool = false
    
    private(set) var backgroundView: UIControl!
    private(set) var collectionView: UICollectionView!
    
    var presenter: TransactionHistoryPresenter!
    
    private var displays: [TransactionHistoryTypes.State.DisplayState] = []
    
    let accountTap: PublishSubject<DomainLayer.DTO.SmartTransaction> = PublishSubject<DomainLayer.DTO.SmartTransaction>()
    let buttonTap: PublishSubject<DomainLayer.DTO.SmartTransaction> = PublishSubject<DomainLayer.DTO.SmartTransaction>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        setupBackgroundView()
        setupCollectionView()
        
        setupSystem()
    }
    
    private func setupBackgroundView() {
        backgroundView = UIControl()
        backgroundView.backgroundColor = UIColor(red: 0 / 255, green: 26 / 255, blue: 57 / 255)
        backgroundView.addTarget(self, action: #selector(backgroundTap(sender:)), for: .touchUpInside)
        view.addSubview(backgroundView)
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        let cv = TransactionHistoryCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView = cv
        cv.touchInsets = TransactionHistoryPopupCell.Constants.popupInsets
        cv.delegate = self
//        cv.panGestureRecognizer.delegate = self
        cv.dataSource = self
        cv.register(TransactionHistoryPopupCell.self, forCellWithReuseIdentifier: "cell")
        cv.alwaysBounceHorizontal = true
        cv.backgroundColor = .clear
        cv.allowsSelection = false
        cv.delaysContentTouches = false
//        cv.isPagingEnabled = true
        cv.isOpaque = false
        
        view.addSubview(cv)
        
        let gr = UIPanGestureRecognizer(target: self, action: #selector(pan(gr:)))
        gr.delegate = self
        view.addGestureRecognizer(gr)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        backgroundView.frame = view.bounds
        collectionView.frame = view.bounds
    }
    
    // MARK: - Action
    
    @objc private func backgroundTap(sender: Any) {
        dismiss(animated: true, completion: nil)
    }
 
    @objc private func pan(gr: UIPanGestureRecognizer) {
        
        var translation = gr.translation(in: view)
        
        switch gr.state {
        case .began:
            
            let location = gr.location(in: view)
            
            if location.y > 60 && location.y < 120 {
                panningEnabled = true
                collectionView.isUserInteractionEnabled = false
                collectionView.isScrollEnabled = false
                collectionViewOffset = collectionView.contentOffset
            }
            
        case .changed:
            
            if !panningEnabled { return }
            
            
            collectionView.setContentOffset(collectionViewOffset, animated: false)
 
            let cvCenter = collectionView.center
            
            let z: CGFloat = cvCenter.y - view.center.y
            var w: CGFloat = 0

            if z < 0 && translation.y < 0 {
                translation.y /= 5
            } else if (z > 0) {
                w = z * Constants.backgroundAlpha / (view.bounds.height - view.center.y)
            }
            
            backgroundView.alpha = Constants.backgroundAlpha - w / 2
            
            collectionView.center = CGPoint(x: cvCenter.x, y: cvCenter.y + translation.y)
            
//            if location.y < 120 && location.y > 60 {
//                print("up")
//                collectionView.center = CGPoint(x: collectionView.center.x, y: collectionView.center.y + translation.y)
////                dismiss(animated: true, completion: nil)
//
//            } else {
//                print("down")
//            }
            
        case .ended:
            
            panningEnabled = false
            collectionView.isScrollEnabled = true
            collectionView.isUserInteractionEnabled = true
            
            let cvCenter = collectionView.center
            
            if cvCenter.y - view.center.y > 60 {
                
                dismiss(animated: true, completion: nil)
                
            } else {
                
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.92, initialSpringVelocity: 15, options: .curveEaseInOut, animations: {
                    
                    self.collectionView.center = self.view.center
                    self.backgroundView.alpha = Constants.backgroundAlpha
                    
                }, completion: nil)
                
            }
            
        default:
            break
        }
        
        gr.setTranslation(.zero, in: view)
        
    }
    
    // MARK: - Content
    
    var currentPage: Int {
        let x = collectionView.contentOffset.x
        let pageWidth: CGFloat = CGFloat(view.bounds.width)
        let minSpace: CGFloat = 10.0
        var page: Double = Double(CGFloat(x) / CGFloat(pageWidth + minSpace))
        
        if page < 0 {
            page = 0
        } else if page >= Double(collectionView.numberOfItems(inSection: 0)) {
            page = Double(collectionView.numberOfItems(inSection: 0)) - Double(1)
        }
        
        return Int(page)
    }
}

extension TransactionHistoryViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
//        if gestureRecognizer == collectionView.panGestureRecognizer {
//            return false
//        } else {
//            return true
//        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if collectionView == nil { return false }
        if gestureRecognizer == collectionView.panGestureRecognizer {
            let location = touch.location(in: view)
            return location.y > 120
        }
        
        return true
    }
    
}

// MARK: - Bind UI

private extension TransactionHistoryViewController {
    
    func setupSystem() {
        
        let feedback: TransactionHistoryPresenterProtocol.Feedback = bind(self) { owner, state in
        
            let subscriptions = owner.uiSubscriptions(state: state)
            let events = owner.events()
            
            return Bindings(subscriptions: subscriptions, events: events)
            
        }
        
        let readyViewFeedback: TransactionHistoryPresenter.Feedback = { [weak self] _ in
            guard let sself = self else { return Signal.empty() }
            return sself
                .rx
                .viewWillAppear
                .take(1)
                .map { _ in TransactionHistoryTypes.Event.readyView }
                .asSignal(onErrorSignalWith: Signal.empty())
        }
        
        presenter.system(feedbacks: [feedback, readyViewFeedback])
        
    }
    
    func events() -> [Signal<TransactionHistoryTypes.Event>] {
        
        return []
        
    }
    
    func uiSubscriptions(state: Driver<TransactionHistoryTypes.State>) -> [Disposable] {
        
        let subscriptionSections = state.drive(onNext: { [weak self] (state) in
            
            guard let sself = self else { return }
            
            sself.displays = state.displays
            
            sself.collectionView.reloadData()
            sself.collectionView.scrollToItem(at: IndexPath(item: state.currentIndex, section: 0), at: .left, animated: false)

        })
        
        return [subscriptionSections]
        
    }
    
}

extension TransactionHistoryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let display = displays[indexPath.item]
        let cell: TransactionHistoryPopupCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TransactionHistoryPopupCell
        
        cell.popupView.contentView.setup(with: display)
        cell.popupView.contentView.delegate = self
//        let popupView = TransactionHistoryPopupView()
//        popupView.contentView.setup(with: display)
//        popupView.contentView.delegate = self
    
        
        
        return cell
        
    }
    
}

extension TransactionHistoryViewController: UICollectionViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if fabs(velocity.x) < fabs(velocity.y) { return }
        
        targetContentOffset.pointee = scrollView.contentOffset
        let pageWidth: CGFloat = CGFloat(view.bounds.width)
        let minSpace: CGFloat = 10.0
        var cellToSwipe: Double = Double(CGFloat(scrollView.contentOffset.x) / CGFloat(pageWidth + minSpace)) + (velocity.x < 0 ? -0.9 : 0.9)
        
        if cellToSwipe < 0 {
            cellToSwipe = 0
        } else if cellToSwipe >= Double(collectionView.numberOfItems(inSection: 0)) {
            cellToSwipe = Double(collectionView.numberOfItems(inSection: 0)) - Double(1)
        }
        
        let indexPath:IndexPath = IndexPath(row: Int(cellToSwipe), section:0)
        collectionView.scrollToItem(at:indexPath, at: UICollectionViewScrollPosition.left, animated: true)
        
    }
    
}

extension TransactionHistoryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.frame.size
        
    }
    
}

extension TransactionHistoryViewController: TransactionHistoryContentViewDelegate {
    
    func contentViewDidPressButton(view: NewTransactionHistoryContentView) {
        
//        let transaction = displays[swipeView.currentItemIndex].sections[0].transaction
//        buttonTap.onNext(transaction)
        
    }
    
    func contentViewDidPressAccount(view: NewTransactionHistoryContentView) {
        
//        let transaction = displays[swipeView.currentItemIndex].sections[0].transaction
//        accountTap.onNext(transaction)
        
    }
    
    func contentViewDidPressNext(view: NewTransactionHistoryContentView) {
        
        let page = self.currentPage + 1
        
        collectionView.scrollToItem(at: IndexPath(item: page, section: 0), at: .left, animated: true)
        
    }
    
    func contentViewDidPressPrevious(view: NewTransactionHistoryContentView) {
        
        let page = self.currentPage - 1
        collectionView.scrollToItem(at: IndexPath(item: page, section: 0), at: .left, animated: true)
        
    }
    
}

extension TransactionHistoryViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presenting = false
        return self
    }
    
}

extension TransactionHistoryViewController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presenting ? 0.4 : 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)
        
        let containerFrame = containerView.frame
        
        if let toView = toView {
            containerView.addSubview(toView)
            toView.frame = containerFrame
        }
        
        if (presenting) {
            backgroundView.alpha = 0
            collectionView.alpha = 0
            collectionView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height * 1.5)
        }
        
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: [.curveEaseOut], animations: {
            
            if self.presenting {
                
                self.backgroundView.alpha = Constants.backgroundAlpha
                self.collectionView.alpha = 1
                self.collectionView.center = self.view.center
                
            } else {
                
                self.backgroundView.alpha = 0
                self.collectionView.center = CGPoint(x: self.view.center.x, y: self.view.bounds.height * 1.5)
                self.collectionView.alpha = 0
                
            }
            
        }, completion: { (success) in
            if (!self.presenting && success) {
                toView?.removeFromSuperview()
            }
            
            transitionContext.completeTransition(success)
        })
    }
    
}
