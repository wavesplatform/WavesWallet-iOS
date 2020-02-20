//
//  ModalTableControllerDataSource.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 19.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit

protocol ModalTableControllerDelegate: AnyObject {

    //weak
    var tableDataSource: UITableViewDataSource? { get }
    
    //weak
    var tableDelegate: UITableViewDelegate? { get }
    
    func modalHeaderView() -> UIView

    func modalHeaderHeight() -> CGFloat
    
    func visibleScrollViewHeight(for size: CGSize) -> CGFloat
    
    func bottomScrollInset(for size: CGSize) -> CGFloat
    
}

