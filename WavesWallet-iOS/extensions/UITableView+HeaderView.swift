//
//  UITableView+HeaderView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

extension UITableView {

    private enum AssociatedKey {
        static var headerView = "headerView"
    }

    private var containerHeaderView: UIView? {

        get {
            return objc_getAssociatedObject(self, &AssociatedKey.headerView) as? UIView
        }

        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKey.headerView, newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func bindHeaderView(_ view: UIView) {

        self.containerHeaderView?.removeFromSuperview()
        self.containerHeaderView = UIView()
        self.containerHeaderView?.translatesAutoresizingMaskIntoConstraints = false
        self.containerHeaderView?.addSubview(view)

        self.tableHeaderView = containerHeaderView

        self.containerHeaderView?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.containerHeaderView?.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        self.containerHeaderView?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true

        self.tableHeaderView?.layoutIfNeeded()
        self.tableHeaderView = self.containerHeaderView
    }
}
