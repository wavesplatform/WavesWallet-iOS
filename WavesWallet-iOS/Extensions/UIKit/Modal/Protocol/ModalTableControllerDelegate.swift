//
//  ModalTableControllerDataSource.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit

protocol ModalTableControllerDelegate: AnyObject {
    
    func modalHeaderView() -> UIView

    func modalHeaderHeight() -> CGFloat
    
    func visibleScrollViewHeight(for size: CGSize) -> CGFloat
    
    func bottomScrollInset(for size: CGSize) -> CGFloat    
}

