//
//  UIView+AddStretchToBounds.swift
//  UITools
//
//  Created by vvisotskiy on 25.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import UIKit

extension UIView {
    public var isVisible: Bool {
        set { self.isHidden = !newValue }
        get { !self.isHidden }
    }
    
    /// Добавляет subview прикрепленную к краям parent с insets
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
    
    /** Удаляет все дочерние view'хи. Подходит в том числе для очистки UIStackView */
    public func removeSubviews() {
      subviews.forEach { $0.removeFromSuperview() }
    }
}
