//
//  NibOwnerLoadable.swift
//  UITools
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import UIKit

public protocol NibOwnerLoadable: class {
    func loadNibContent()
}

public extension NibOwnerLoadable where Self: UIView {
    func loadNibContent() {
        let views = Self._nib.instantiate(withOwner: self, options: nil)
        if let view = views.first(where: { $0 is UIView }) as? UIView {
            addSubview(view)
            backgroundColor = view.backgroundColor
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: topAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor),
                view.leadingAnchor.constraint(equalTo: leadingAnchor),
                view.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
        } else {
            fatalError("Dont have view from nib")
        }
    }
}

// MARK: - Private

private extension NibOwnerLoadable {
    static var _nib: UINib {
        UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

private extension NibOwnerLoadable where Self: Reusable {
    static var _nib: UINib {
        UINib(nibName: reuseIdentifier, bundle: Bundle(for: self))
    }
}

private extension NibOwnerLoadable where Self: NibLoadable {
    static var _nib: UINib { nib }
}
