//
//  UIView+isVisible.swift
//  UITools
//
//  Created by vvisotskiy on 25.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import UIKit

extension UIView {
    /// 
    public var isVisible: Bool {
        set {
            self.isHidden = !newValue
        }
        
        get {
            !self.isHidden
        }
    }
}
