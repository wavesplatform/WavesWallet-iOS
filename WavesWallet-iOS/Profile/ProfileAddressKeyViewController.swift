//
//  ProfileAddressesViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class ProfileAddressKeyViewController: UIViewController {

    @IBOutlet weak var buttonPublicKey: UIButton!
    @IBOutlet weak var buttonCopyAddress: UIButton!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelPublicKey: UILabel!
    @IBOutlet weak var labelPrivateKey: UILabel!
    @IBOutlet weak var buttonPrivateKey: UIButton!
    @IBOutlet weak var buttonShowPrivateKey: UIButton!
    
    @IBOutlet weak var scrollAliasOffset: NSLayoutConstraint!
    @IBOutlet weak var scrollAliasHeight: NSLayoutConstraint!
    @IBOutlet weak var separatorViewOffset: NSLayoutConstraint!
    @IBOutlet weak var separatorButtonOffset: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewAliases: UIScrollView!
    
    @IBOutlet weak var labelAliases: UILabel!
    let aliases : [String] = ["makstorch", "pimp-man", "ol-dirty-bastard"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = .white
        createBackButton()
        title = "Addresses and keys"
        
        setupPrivateKeyState(isShow: false, animation: false)
        setupAliases()
    }

    override func viewWillAppear(_ animated: Bool) {
        setupSmallNavigationBar()
        hideTopBarLine()
    }
    
    func copyTapped(_ sender: UIButton) {
        
        let value = aliases[sender.tag]
        
        setupButtonCopyState(sender)
    }
    
    func setupAliases() {
        
        if aliases.count == 0 {
            labelAliases.isHidden = true
            scrollAliasHeight.constant = 0
            scrollAliasOffset.constant = -40
        }
        
        var offset : CGFloat = 14
        for (index, value) in aliases.enumerated() {
            
            let view = ProfileAliasView.loadView() as! ProfileAliasView
            view.setup(title: value)
            view.buttonCopy.addTarget(self, action: #selector(copyTapped(_:)), for: .touchUpInside)
            view.buttonCopy.tag = index
            view.frame.origin.x = offset
            offset += view.frame.size.width + 8
            scrollViewAliases.addSubview(view)
        }
        
        if let subView = scrollViewAliases.subviews.last {
            scrollViewAliases.contentSize = CGSize(width: subView.frame.origin.x + subView.frame.size.width + 8,
                                                   height: scrollViewAliases.contentSize.height)
        }
        labelAliases.text = "Aliases (\(aliases.count))"
    }
    
    @IBAction func createNewAlias(_ sender: Any) {
    
        let controller = storyboard?.instantiateViewController(withIdentifier: "CreateAliasViewController") as! CreateAliasViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func showPrivateKey(_ sender: Any) {
        
        setupPrivateKeyState(isShow: true, animation: true)
    }
    
    func setupPrivateKeyState(isShow: Bool, animation: Bool) {
        
        if isShow {
            
            separatorButtonOffset.isActive = false

            UIView.animate(withDuration: animation ? 0.3 : 0) {
                self.labelPrivateKey.alpha = 1
                self.buttonPrivateKey.alpha = 1
                self.buttonShowPrivateKey.alpha = 0
                self.view.layoutIfNeeded()
            }
        }
        else {
            separatorButtonOffset.isActive = true

            UIView.animate(withDuration: animation ? 0.3 : 0) {
                self.labelPrivateKey.alpha = 0
                self.buttonPrivateKey.alpha = 0
                self.buttonShowPrivateKey.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func setupButtonCopyState(_ sender: Any) {
        let button = sender as! UIButton
        button.setImage(UIImage(named: "check_success"), for: .normal)
        button.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            button.setImage(UIImage(named: "copy_black"), for: .normal)
            button.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func copyPrivateKey(_ sender: Any) {
        UIPasteboard.general.string = labelPrivateKey.text
        setupButtonCopyState(sender)
    }
    
    @IBAction func copyPublicKeyTapped(_ sender: Any) {

        UIPasteboard.general.string = labelPublicKey.text
        setupButtonCopyState(sender)
    }
    
    @IBAction func copyAddressTapped(_ sender: Any) {
        UIPasteboard.general.string = labelAddress.text

        setupButtonCopyState(sender)
    }
    
}
