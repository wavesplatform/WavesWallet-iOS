//
//  DeviceLayoutConstraint.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 13.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import DeviceKit

public extension Device {
    enum Inch: Double, Equatable {
                
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
        
        static var smallDevices: [Inch] {
            return [.inch3_5, .inch4, .inch4_7, .inch5_5]
        }
        
        static var mediumDevices: [Inch] {
            return [.inch5_8, .inch6_1]
        }
        
        static var largeDevices: [Inch] {
            return [.inch6_5]
        }
    }
    
    var isSmallDevices: Bool {
        return Inch.smallDevices.contains(currentInch)
    }
    
    var isMediumDevices: Bool {
        return Inch.mediumDevices.contains(currentInch)
    }
    
    var isLargeDevices: Bool {
        return Inch.largeDevices.contains(currentInch)
    }
            
    var currentInch: Device.Inch {
        return Device.Inch.init(rawValue: diagonal) ?? Device.Inch.inch4
    }
}



class DeviceLayoutConstraint: NSLayoutConstraint {
    
    @IBInspectable var smallDevices: CGFloat = 0.0 {
        didSet {
            updateConstant(sizes: Device.Inch.smallDevices, constant: inch3_5)
        }
    }
    
    @IBInspectable var mediumDevices: CGFloat = 0.0 {
        didSet {
            updateConstant(sizes: Device.Inch.mediumDevices, constant: inch3_5)
        }
    }
    
    @IBInspectable var largeDevices: CGFloat = 0.0 {
        didSet {
            updateConstant(sizes: Device.Inch.largeDevices, constant: inch3_5)
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
    
    fileprivate func updateConstant(size: Device.Inch, constant: CGFloat) {
        updateConstant(sizes: [size], constant: constant)
    }
    
    fileprivate func updateConstant(sizes: [Device.Inch], constant: CGFloat) {
        let currentInch = Device.current.currentInch.rawValue
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
