//
//  UIViewController+SafeArea.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 09.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

import UIKit

extension UIViewController {

    var layoutInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIEdgeInsets(top: view.safeAreaInsets.top,
                                left: view.safeAreaInsets.left,
                                bottom: view.safeAreaInsets.bottom,
                                right: view.safeAreaInsets.right)
        } else {
            return UIEdgeInsets(top: topLayoutGuide.length,
                                left: 0,
                                bottom: bottomLayoutGuide.length,
                                right: 0)
        }
    }
}

protocol LayoutGuideProvider {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: LayoutGuideProvider { }
extension UILayoutGuide: LayoutGuideProvider { }

extension UIView {
    var compatibleSafeAreaLayoutGuide: LayoutGuideProvider {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide
        } else {
            return self
        }
    }
}
