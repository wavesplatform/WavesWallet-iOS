//
//  SideMenu.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 17/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RESideMenu

final class SlideMenu: RESideMenu {

    override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.contentViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentViewShadowEnabled = true
        panGestureEnabled = false
        interactivePopGestureRecognizerEnabled = false
        panFromEdge = false
        interactivePopGestureRecognizerEnabled = true
        contentViewShadowOffset = CGSize(width: 0, height: 10)
        contentViewShadowOpacity = 0.2
        contentViewShadowRadius = 15

        //        sideMenuViewController.contentViewScaleValue = 1
        contentViewInPortraitOffsetCenterX = 100
    }
}
