//
//  TransactionHistoryCollectionView.swift
//  WavesWallet-iOS
//
//  Created by Mac on 18/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class TransactionHistoryCollectionView: UICollectionView {
    
    var touchInsets: UIEdgeInsets = .zero
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        if point.y < touchInsets.top {
            return nil
        }
        
        return super.hitTest(point, with: event)
    }
    
}
