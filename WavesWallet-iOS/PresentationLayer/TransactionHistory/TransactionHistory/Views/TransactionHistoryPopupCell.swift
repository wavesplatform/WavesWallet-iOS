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
    }
    
    var popupLineView: UIView!
    var shadowView: UIView!
    var popupView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        popupLineView = UIView()
        popupLineView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        popupLineView.layer.cornerRadius = 4
        
        shadowView = UIView(frame: contentView.frame)
        shadowView.backgroundColor = .white
        shadowView.layer.cornerRadius = 10
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: -2)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 3
        contentView.addSubview(shadowView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let insets = Constants.popupInsets
        
        if let popupView = popupView {
            popupView.frame = CGRect(x: insets.left, y: insets.top, width: bounds.width - insets.left - insets.right, height: bounds.height - insets.top)
            shadowView.frame = popupView.frame
//            shadowView.center = .init(x: shadowView.center.x, y: shadowView.center.y - 20)
        }
        
        popupView?.layer.clip(roundedRect: nil, byRoundingCorners: [.topLeft, .topRight], cornerRadius: 10, inverse: false)
//        roundCorners(cornerRadius: 10.0)
        
        let popupLineSize = CGSize(width: 36, height: 4)
        popupLineView.frame = CGRect(x: (bounds.width - popupLineSize.width) / 2, y: 6, width: popupLineSize.width, height: popupLineSize.height)
    }
    
    func fill(with popupView: UIView) {
        self.popupView = popupView
        
        contentView.addSubview(popupView)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
                popupView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).cgColor
                popupView.layer.shadowRadius = 3
                popupView.layer.shadowOffset = .init(width: 0, height: -2)
        
        popupView.addSubview(popupLineView)
    }
  
    func roundCorners(cornerRadius: Double) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = popupView!.bounds
        maskLayer.path = path.cgPath
        popupView?.layer.mask = maskLayer
    }
    
}
