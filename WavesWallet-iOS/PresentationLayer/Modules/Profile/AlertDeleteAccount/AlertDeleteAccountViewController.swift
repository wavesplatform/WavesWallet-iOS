//
//  DeleteAccountViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class AlertDeleteAccountViewController: UIViewController {

    private var window: UIWindow? = nil

    var deleteBlock : (() -> Void)?
    var cancelBlock : (() -> Void)?
    
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        deleteButton.setTitle(Localizable.Waves.Profile.Alert.Deleteaccount.Button.delete, for: .normal)
        cancelButton.setTitle(Localizable.Waves.Profile.Alert.Deleteaccount.Button.cancel, for: .normal)
        titleLabel.text = Localizable.Waves.Profile.Alert.Deleteaccount.title
        messageLabel.text = Localizable.Waves.Profile.Alert.Deleteaccount.message
    }

    func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
        }) { _ in
            self.window?.rootViewController = nil
            self.window = nil
        }
    }

    func showInController(_ inController: UIViewController) {

        let window = UIWindow()
        window.bounds = UIScreen.main.bounds
        window.rootViewController = self
        window.backgroundColor = .clear
        window.makeKeyAndVisible()
        self.window = window

        view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 1
        }

        viewContainer.addBounceStartAnimation()
    }

    // MARK: Actions
    
    @IBAction func deleteTapped(_ sender: Any) {
    
        if let block = deleteBlock {
            block()
        }
        
        viewContainer.addBounceEndAnimation()
        dismiss()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        
        if let block = cancelBlock {
            block()
        }
        
        viewContainer.addBounceEndAnimation()
        dismiss()
    }
}
