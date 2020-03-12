//
//  ReceiveAddressView.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 09.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

private enum Constants {
    static let padding: CGFloat = 16
    static let paddingBetweenCard: CGFloat = 8
}

protocol ReceiveAddressViewDelegate: AnyObject {        
    func sharedTapped(_ info: ReceiveAddress.ViewModel.Address)
    func closeTapped()
}

final class ReceiveAddressView: UIView {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var segmentedControl: NewSegmentedControl!
    @IBOutlet private weak var closeButton: UIButton!
    
    private lazy var leftGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,
                                                                                 action: #selector(handlerLeftGesture))
    
    private lazy var rightGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,
                                                                                       action: #selector(handlerRightGesture))
    
    private var receiveAddressViews: [ReceiveAddressCardView] = .init()
    
    weak var delegate: ReceiveAddressViewDelegate? = nil
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var frame: CGRect = CGRect.init(x: Constants.padding,
                                        y: 0,
                                        width: scrollView.frame.width - Constants.padding * 2,
                                        height: scrollView.frame.height)
                
        var contentWidth: CGFloat = Constants.padding
        
        receiveAddressViews
            .forEach { (view) in
                    
                view.frame = frame
                frame.origin = CGPoint(x: frame.origin.x + frame.width + Constants.paddingBetweenCard,
                                       y: 0)
                
                contentWidth += frame.width + Constants.paddingBetweenCard
            }
        
        contentWidth += Constants.paddingBetweenCard
        scrollView.contentSize = CGSize(width: contentWidth,
                                        height: scrollView.frame.height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.isPagingEnabled = false
        scrollView.isScrollEnabled = false
        scrollView.addGestureRecognizer(leftGesture)
        scrollView.addGestureRecognizer(rightGesture)
    
        leftGesture.direction = .left
        rightGesture.direction = .right
        
        backgroundColor = .submit700
                
        closeButton.setTitle(Localizable.Waves.Receiveaddress.Button.close, for: .normal)
        
        segmentedControl.segmentedDelegate = self
        segmentedControl.selectedColor = .white
        segmentedControl.lineColor = .white
        segmentedControl.unselectedColor = .submit200
    }

    @objc func handlerLeftGesture(gesture: UIPanGestureRecognizer) {
        
        let pageWidth: CGFloat = cardWidth()
        
        let x = min(scrollView.contentSize.width - scrollView.frame.width, scrollView.contentOffset.x + pageWidth)
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        segmentedControl.setSelectedIndex(index(contentOffsetX: x), animation: true)
    }
    
    @objc func handlerRightGesture(gesture: UIPanGestureRecognizer) {
        
        let pageWidth: CGFloat = cardWidth()
        
        let x = max(0, scrollView.contentOffset.x - pageWidth)
        scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
        segmentedControl.setSelectedIndex(index(contentOffsetX: x), animation: true)
    }
        
    @IBAction func closeTapped(_ sender: Any) {
        self.delegate?.closeTapped()
    }
}

// MARK: Private Card View

private extension ReceiveAddressView {
    
    var currentIndex: Int {
        return index(contentOffsetX: scrollView.contentOffset.x)
    }
    
    func index(contentOffsetX: CGFloat) -> Int {
        return Int(round(contentOffsetX / cardWidth()))
    }
    
    func contentOffsetX(index: Int) -> CGFloat {
        return cardWidth() * CGFloat(index)
    }
    
    func cardWidth() -> CGFloat {
        return scrollView.frame.width - Constants.padding - Constants.paddingBetweenCard
    }
    
    private func removeAllReceiveAddressCardViews() {
        self.receiveAddressViews.forEach { $0.removeFromSuperview() }
        self.receiveAddressViews.removeAll()
    }
    
    private func addressCardView(model: ReceiveAddress.ViewModel.Address) -> ReceiveAddressCardView {
        
        let view: ReceiveAddressCardView = ReceiveAddressCardView.loadView()
        view.translatesAutoresizingMaskIntoConstraints = true
        view.update(with: model)
        return view
    }
}

// MARK: ViewConfiguration

extension ReceiveAddressView: ViewConfiguration {
    
    func update(with model: [ReceiveAddress.ViewModel.Address]) {
                        
        segmentedControl.isHidden = model.count < 1
        
        segmentedControl.update(with: model.map { NewSegmentedControl.SegmentedItem.title($0.addressTypeName) })
        
        removeAllReceiveAddressCardViews()
                        
        model.forEach {
            let addressView = self.addressCardView(model: $0)
            addressView.shareTapped = { [weak self] model in
                self?.delegate?.sharedTapped(model)
            }
            self.receiveAddressViews.append(addressView)
            scrollView.addSubview(addressView)
        }
        
        setNeedsLayout()
    }
}

extension ReceiveAddressView: NewSegmentedControlDelegate {

    func segmentedControlDidChangeIndex(_ index: Int) {
        scrollView.setContentOffset(CGPoint(x: contentOffsetX(index: index),
                                            y: 0),
                                    animated: true)
    }
}
