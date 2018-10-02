//
//  ReceiveContainerViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class ReceiveContainerViewController: UIViewController {

    private var viewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Localizable.Receive.Label.receive
    }


    
}

//MARK: - Methods

extension ReceiveContainerViewController {
    
    func add(_ viewController: UIViewController) {
        viewControllers.append(viewController)
    }
}
