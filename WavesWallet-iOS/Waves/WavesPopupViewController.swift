//
//  WavesPopupViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/30/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RESideMenu

protocol WavesPopupModuleOutput: AnyObject {
    func showSend()
    func showReceive()
    func showExchange()
}

final class WavesPopupViewController: UIViewController {

    weak var moduleOutput: WavesPopupModuleOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func sendTapped(_ sender: Any) {

        moduleOutput?.showSend()
        dismissTapped(sender)
    }
    
    
    @IBAction func receiveTapped(_ sender: Any) {
        
        moduleOutput?.showReceive()
        dismissTapped(sender)
    }
    
    
    @IBAction func exchangeTapped(_ sender: Any) {
        moduleOutput?.showExchange()
    }
    
    
    @IBAction func dismissTapped(_ sender: Any) {
        
        if let parent = parent as? PopupViewController {
            parent.dismissPopup()
        }
    }
    
    
    deinit {
        debug("WavesPopupViewController deinit")
    }
    
}
