//
//  UIView+AddStretchToBounds.swift
//  UITools
//
//  Created by vvisotskiy on 25.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import UIKit

extension UIView {
    /// 
    public func addStretchToBounds(_ view: UIView, insets: UIEdgeInsets = UIEdgeInsets.zero) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
        ])
    }
}
