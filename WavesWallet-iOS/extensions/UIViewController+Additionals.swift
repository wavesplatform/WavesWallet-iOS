//
//  UIViewController+Additionals.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

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

    // TODO: Меня смущает проверка (<= 44) в showImage.
    func setupTopBarLine() {
        
        if let nav = navigationController {
            let showImage = nav.navigationBar.frame.size.height.rounded(.down) <= 44
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
    
    func addBgBlueImage() {
        let imageView = UIImageView(frame: UIScreen.main.bounds)

        if Platform.isIphone5 {
            imageView.image = UIImage(named: "bg-iphone5")
        } else if Platform.isIphoneX {
            imageView.image = UIImage(named: "bg-iphonex")
        } else if Platform.isIphonePlus {
            imageView.image = UIImage(named: "bg-iphone8plus")
        } else {
            imageView.image = UIImage(named: "bg-iphone8")
        }
        
        view.insertSubview(imageView, at: 0)
    }
}
