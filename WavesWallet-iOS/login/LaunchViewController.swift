//
//  LaunchViewController.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 20/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit
import MBProgressHUD
import RxSwift

class LaunchViewController: UIViewController {

    @IBOutlet weak var createWalletButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var importWalletButton: UIButton!
    var envButton: UIBarButtonItem!
    
    var numLogoTap = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        envButton = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(onChooseEnvironment(_:)))
        envButton.tintColor = AppColors.activeColor
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    @IBAction func onImportWallet(_ sender: Any) {
        //let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        //hud.backgroundView.style = .blur
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImportWallet", let vc = segue.destination as? CreateNewWalletViewController {
            vc.isCreateNew = false
        }
    
    }
    @IBAction func onChooseEnvironment(_ sender: Any) {
        let options = [Environments.Mainnet, Environments.Testnet]
            
            let vc = UIAlertController(title: "Choose Environment", message: "", preferredStyle: .actionSheet)
            vc.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            for env in options {
                vc.addAction(UIAlertAction(title: env.name, style: .default, handler: { _ in
                    Environments.current = env
                }))
            }
            
            present(vc, animated: true, completion: nil)
    }

    @IBAction func onLogo(_ sender: Any) {
        numLogoTap += 1
        if numLogoTap > 5 {
            self.navigationItem.leftBarButtonItem = envButton
        }
    }

}
