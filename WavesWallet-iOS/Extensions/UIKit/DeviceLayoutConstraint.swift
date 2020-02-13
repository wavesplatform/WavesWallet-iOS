//
//  DeviceLayoutConstraint.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 13.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import DeviceKit

class DeviceLayoutConstraint: NSLayoutConstraint {
    
    enum Inch: Double {
                
        case inch3_5 = 3.5
        case inch4 = 4
        case inch4_7 = 4.7
        case inch5_5 = 5.5
        case inch5_8 = 5.8
        case inch6_1 = 6.1
        case inch6_5 = 6.5
        case inch7_9 = 7.9
        case inch9_7 = 9.7
        case inch10_5 = 10.5
        case inch12_9 = 12.9
    }
    
    @IBInspectable var inch3_5: CGFloat = 0.0 {
        didSet {
            updateConstant(size: .inch3_5, constant: inch3_5)
        }
    }
    
    @IBInspectable var inch4: CGFloat = 0.0 {
        didSet {
            updateConstant(size: .inch4, constant: inch4)
        }
    }
    
    @IBInspectable var inch4_7: CGFloat = 0.0 {
        didSet {
            updateConstant(size: .inch4_7, constant: inch4_7)
        }
    }
    
    @IBInspectable var inch5_5: CGFloat = 0.0 {
        didSet {
            updateConstant(size: .inch5_5, constant: inch5_5)
        }
    }
    
    @IBInspectable var inch5_8: CGFloat = 0.0 {
        didSet {
            updateConstant(size: .inch5_8, constant: inch5_8)
        }
    }
    
    @IBInspectable var inch6_1: CGFloat = 0.0 {
        didSet {
            updateConstant(size: .inch6_1, constant: inch6_1)
        }
    }
    
    @IBInspectable var inch6_5: CGFloat = 0.0 {
        didSet {
            updateConstant(size: .inch6_5, constant: inch6_5)
        }
    }
    
    @IBInspectable var inch7_9: CGFloat = 0.0 {
        didSet {
            updateConstant(size: .inch7_9, constant: inch7_9)
        }
    }
    
    @IBInspectable var inch9_7: CGFloat = 0.0 {
        didSet {
            updateConstant(size: .inch9_7, constant: inch9_7)
        }
    }
    
    @IBInspectable var inch10_5: CGFloat = 0.0 {
        didSet {
            updateConstant(size: .inch10_5, constant: inch10_5)
        }
    }
    
    @IBInspectable var inch12_9: CGFloat = 0.0 {
        didSet {
            updateConstant(size: .inch12_9, constant: inch12_9)
        }
    }
    
    fileprivate func updateConstant(size: Inch, constant: CGFloat) {
        if size == deviceSize() {
            self.constant = constant
            layoutIfNeeded()
        }
    }
    
    open func deviceSize() -> DeviceLayoutConstraint.Inch {
        return DeviceLayoutConstraint.Inch.init(rawValue: Device.current.diagonal) ?? DeviceLayoutConstraint.Inch.inch4
    }
    
    open func layoutIfNeeded() {
        firstItem?.layoutIfNeeded()
        secondItem?.layoutIfNeeded()
    }
}

