//
//  UIViewController+Additionals.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit
//import DomainLayer

private enum Constants {
    static let smallNavBarHeight: CGFloat = 44
    static let bigNavBarHeight: CGFloat = 96
}

extension UIViewController {

    func createBackWhiteButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Images.topbarBackwhite.image.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backTapped))
    }

    func createBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Images.btnBack.image.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backTapped))
    }


    func createMenuButton(isWhite: Bool = false) {
        let item = UIBarButtonItem(image: UIImage(named: "icon_menu"), style: .done, target: self, action: #selector(menuTapped))

        if isWhite {
            item.tintColor = .white
        }

        navigationItem.leftBarButtonItem = item
    }

    @objc func menuTapped() {

        //TODO: ALARM
//        UseCasesFactory
//            .instance
//            .analyticManager
//            .trackEvent(.menu(.wavesMenuPage))
        
        let menu = AppDelegate.shared().menuController
        menu.presentLeftMenuViewController()
    }
    
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    func hideTopBarLine() {
        navigationItem.shadowImage = UIImage()
    }

    func showTopBarLine() {
        navigationItem.shadowImage = UIViewController.shadowImage
    }
    
    var isShowNotFullBigNavigationBar: Bool {
        return navigationController?.navigationBar.frame.size.height.rounded(.down) ?? 0 < Constants.bigNavBarHeight
    }

    var isSmallNavigationBar: Bool {
        
        if let nav = navigationController {
            return nav.navigationBar.frame.size.height.rounded(.down) <= Constants.smallNavBarHeight
        }
        return false
    }

    func setupTopBarLine() {
        
        if isSmallNavigationBar {
            navigationItem.shadowImage = UIViewController.shadowImage
        }
        else {
            navigationItem.shadowImage = UIViewController.cleanShadowImage
        }
    }
    
    func setupSmallNavigationBar() {
        if #available(iOS 11.0, *) {
            navigationItem.prefersLargeTitles = false
        }
    }
    
    func setupBigNavigationBar() {
        if #available(iOS 11.0, *) {
            navigationItem.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .automatic
        }
    }

    static var shadowImage: UIImage? = {
        return UIImage.shadowImage(color: .accent100)
    }()
    
    static var cleanShadowImage: UIImage = {
        return UIImage()
    }()
    
    func tableViewTopOffsetForBigNavBar(_ tableView: UITableView) -> CGPoint {
        
        //TODO: check if IOS 10 will be support
        let navBarY = (navigationController?.navigationBar.frame.origin.y ?? 0)
        let offset = -(Constants.bigNavBarHeight + navBarY + tableView.contentInset.top)
        return CGPoint(x: 0, y: offset)
    }
    
    func findNavigationController() -> UINavigationController? {
        var current: UIResponder? = self
        
        while (current != nil) {
            
            if let nav = current as? UINavigationController {
                return nav
            }
            
            current = current?.next
        }
        
        return nil
    }
}
