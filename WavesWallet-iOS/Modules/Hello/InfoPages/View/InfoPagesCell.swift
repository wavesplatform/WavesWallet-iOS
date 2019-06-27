//
//  InfoPagesCell.swift
//  WavesWallet-iOS
//
//  Created by Mac on 12/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class InfoPagesCell: UICollectionViewCell, Reusable {
    
    fileprivate var infoView: UIView?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        infoView?.frame = bounds
    }
    
}

extension InfoPagesCell: ViewConfiguration {
    
    func update(with model: UIView) {
        
        infoView?.removeFromSuperview()
        infoView = nil
        
        infoView = model
        contentView.addSubview(model)
        
        setNeedsLayout()
        layoutIfNeeded()
        
    }
    
}
