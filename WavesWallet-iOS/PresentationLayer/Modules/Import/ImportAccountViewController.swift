//
//  ImportAccountViewController.swift
//  WavesWallet-iOS
//
//  Created by Mac on 08/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class ImportAccountViewController: UIViewController {
    
    override func viewDidLoad() {
       title = Localizable.Waves.Import.General.Navigation.title
        
        setupBigNavigationBar()
        createBackButton()
        hideTopBarLine()
    }
    
}

