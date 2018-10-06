//
//  TransactionHistoryPopupCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 17/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class TransactionHistoryPopupCell: UICollectionViewCell {
    
    enum Constants {
        static let popupInsets = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        static let popupLineColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        static let popupLineCornerRadius: CGFloat = 4
        static let popupLineSize: CGSize = CGSize(width: 36, height: 4)
        
        static let shadowViewCornerRadius: CGFloat = 10
        static let shadowOffset: CGSize = CGSize(width: 0, height: -2)
        static let shadowOpacity: CGFloat = 0.2
        static let shadowRadius: CGFloat = 3
    }
    
    private var popupLineView: UIView!
    private var shadowView: UIView!
    var popupView: TransactionHistoryPopupView!
    
    var navigationBarHeight: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        popupLineView = UIView()
        popupLineView.backgroundColor = Constants.popupLineColor
        popupLineView.layer.cornerRadius = Constants.popupLineCornerRadius
        
        shadowView = UIView(frame: contentView.frame)
        shadowView.backgroundColor = .white
        shadowView.layer.cornerRadius = Constants.shadowViewCornerRadius
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = Constants.shadowOffset
        shadowView.layer.shadowOpacity = Float(Constants.shadowOpacity)
        shadowView.layer.shadowRadius = Constants.shadowRadius
        contentView.addSubview(shadowView)
        
        setupPopupView()
    }
    
    private func setupPopupView() {
        popupView = TransactionHistoryPopupView()
        
        contentView.addSubview(popupView!)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
//        popupView?.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).cgColor
//        popupView?.layer.shadowRadius = 3
//        popupView?.layer.shadowOffset = .init(width: 0, height: -2)
        
        popupView?.addSubview(popupLineView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let insets = Constants.popupInsets
        
        if let popupView = popupView {
            popupView.frame = CGRect(x: insets.left, y: topInset, width: bounds.width - insets.left - insets.right, height: bounds.height - topInset)
            shadowView.frame = popupView.frame
        }
        
        popupView?.layer.clip(roundedRect: nil, byRoundingCorners: [.topLeft, .topRight], cornerRadius: 10, inverse: false)
        
        let popupLineSize = Constants.popupLineSize
        popupLineView.frame = CGRect(x: (bounds.width - popupLineSize.width) / 2, y: 6, width: popupLineSize.width, height: popupLineSize.height)
    }
    
    var topInset: CGFloat {
        
        if #available(iOS 11.0, *) {
 
            return safeAreaInsets.top + navigationBarHeight
        }
        
        return Constants.popupInsets.top
    }
  
    func roundCorners(cornerRadius: Double) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = popupView!.bounds
        maskLayer.path = path.cgPath
        popupView?.layer.mask = maskLayer
    }
    
}
