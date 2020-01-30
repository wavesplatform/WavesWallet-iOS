//
//  WavesPopupViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/30/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import UIKit
import RESideMenu

protocol WavesPopupModuleOutput: AnyObject {
    func showSend()
    func showReceive()
}

final class WavesPopupViewController: UIViewController {

    weak var moduleOutput: WavesPopupModuleOutput?    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var receiveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.setTitle(Localizable.Waves.Wavespopup.Button.send, for: .normal)
        receiveButton.setTitle(Localizable.Waves.Wavespopup.Button.receive, for: .normal)
    }

    @IBAction func sendTapped(_ sender: Any) {

        moduleOutput?.showSend()
        dismissTapped(sender)
    }
    
    
    @IBAction func receiveTapped(_ sender: Any) {
        
        moduleOutput?.showReceive() 
        dismissTapped(sender)
    }
        
    @IBAction func dismissTapped(_ sender: Any) {
        if let parent = parent as? PopupViewController {
            parent.dismissPopup()
        }
    }
}
