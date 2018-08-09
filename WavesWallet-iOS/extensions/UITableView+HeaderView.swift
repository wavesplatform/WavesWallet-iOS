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


extension UINavigationItem {

    private enum AssociatedKey {
        static var titleView = "titleView"
    }

    private var containerTitleView: UIView? {

        get {
            return objc_getAssociatedObject(self, &AssociatedKey.titleView) as? UIView
        }

        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKey.titleView, newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func bindTitleView(_ view: UIView) {

//        self.containerTitleView?.removeFromSuperview()
//        self.containerTitleView = UIView()
//        self.containerTitleView?.translatesAutoresizingMaskIntoConstraints = false
//        self.containerTitleView?.addSubview(view)


        
        
//        self.containerTitleView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        self.containerTitleView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        self.containerTitleView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        self.containerTitleView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

//        self.titleView?.layoutIfNeeded()
//        self.titleView = self.containerTitleView
    }
}
