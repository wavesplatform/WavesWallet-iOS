//
//  MenuViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var firstOffset: NSLayoutConstraint!
    @IBOutlet weak var secondOffset: NSLayoutConstraint!
    @IBOutlet weak var bottomOffset: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Platform.isIphone5 {
            firstOffset.constant = 0
            secondOffset.constant = 20
            bottomOffset.constant = 20
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}
