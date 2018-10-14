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

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override init!(contentViewController: UIViewController!, leftMenuViewController: UIViewController!, rightMenuViewController: UIViewController!) {
        super.init(contentViewController: contentViewController, leftMenuViewController: leftMenuViewController, rightMenuViewController: rightMenuViewController)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        contentViewShadowEnabled = true
        panGestureEnabled = false
        interactivePopGestureRecognizerEnabled = false
        panFromEdge = false
        interactivePopGestureRecognizerEnabled = true
        contentViewShadowOffset = CGSize(width: 0, height: 10)
        contentViewShadowOpacity = 0.2
        contentViewShadowRadius = 15
        contentViewInPortraitOffsetCenterX = 100
    }
}
