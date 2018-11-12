//
//  UIViewController+Additionals.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

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
        navigationItem.shadowImage = nil
    }
    
    var isShowNotFullBigNavigationBar: Bool {
        return navigationController?.navigationBar.frame.size.height.rounded(.down) ?? 0 < Constants.bigNavBarHeight
    }

    var isSmallNavigationBar: Bool {
        return navigationController?.navigationBar.frame.size.height.rounded(.down) ?? 0 <= Constants.smallNavBarHeight
    }

    // TODO: Меня смущает проверка (<= 44) в showImage.
    func setupTopBarLine() {
        
        if let nav = navigationController {
            let showImage = nav.navigationBar.frame.size.height.rounded(.down) <= Constants.smallNavBarHeight
            if showImage {
                if navigationItem.shadowImage != nil {
                    navigationItem.shadowImage = nil
                }
            } else {
                if navigationItem.shadowImage == nil {
                    navigationItem.shadowImage = UIImage()
                }
            }
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

}
