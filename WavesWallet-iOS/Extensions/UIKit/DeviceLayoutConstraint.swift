//
//  DeviceLayoutConstraint.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 13.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

public class DeviceLayoutConstraint: NSLayoutConstraint {
        
    @IBInspectable var smallDevices: CGFloat = 0.0 {
        didSet {
            updateConstant(sizes: Platform.Inch.smallDevices, constant: inch3_5)
        }
    }
    
    @IBInspectable var mediumDevices: CGFloat = 0.0 {
        didSet {
            updateConstant(sizes: Platform.Inch.mediumDevices, constant: inch3_5)
        }
    }
    
    @IBInspectable var largeDevices: CGFloat = 0.0 {
        didSet {
            updateConstant(sizes: Platform.Inch.largeDevices, constant: inch3_5)
        }
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
    
    fileprivate func updateConstant(size: Platform.Inch, constant: CGFloat) {
        updateConstant(sizes: [size], constant: constant)
    }
    
    fileprivate func updateConstant(sizes: [Platform.Inch], constant: CGFloat) {
        let currentInch = Platform.currentInch.rawValue
        if sizes.contains(where: { $0.rawValue == currentInch }) {
            self.constant = constant
            layoutIfNeeded()
        }
    }
        
    open func layoutIfNeeded() {
        firstItem?.layoutIfNeeded()
        secondItem?.layoutIfNeeded()
    }
}
