//
//  ContainerContentConstraints.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 05.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit

typealias VoidClosure = () -> Void

public final class ContainerContentConstraints {
    
    /// Ссылка на верхний констрейнт
    public weak var top: NSLayoutConstraint?
    
    /// Ссылка на нижний констрейнт
    public weak var bottom: NSLayoutConstraint?
    
    /// Ссылка на левый констрейнт
    public weak var leading: NSLayoutConstraint?
    
    /// Ссылка на правый констрейнт
    public weak var trailing: NSLayoutConstraint?

    public init() {}

    /// Метод обновление констант констрейнтов
    public func updateWith(_ insets: UIEdgeInsets) {
        top?.constant = insets.top
        bottom?.constant = insets.bottom
        leading?.constant = insets.left
        trailing?.constant = insets.right
    }
}
