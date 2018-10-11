//
//  MailCompose+Support swift.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 11/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import MessageUI

final class MailComposeCoordinator: NSObject, Coordinator, MFMailComposeViewControllerDelegate {

    var childCoordinators: [Coordinator] = []
    var parent: Coordinator?

    private var email: String
    private var viewController: UIViewController

    init(viewController: UIViewController, email: String) {
        self.viewController = viewController
        self.email = email
    }

    func start() {

        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.setMessageBody(UIDevice.current.deviceDescription(), isHTML: false)
            vc.setToRecipients([email])
            vc.mailComposeDelegate = self
            viewController.present(vc, animated: true, completion: nil)
        } else {

            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
                self.removeFromParentCoordinator()
            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
                self.removeFromParentCoordinator()
            }))

            viewController.present(alert, animated: true, completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        removeFromParentCoordinator()
    }


//    if #available(iOS 10.0, *)
//    {
//    UIApplication.sharedApplication().openURL(NSURL(string:"App-Prefs:root=SOMETHING")!)
//    }
//    else
//    {
//    UIApplication.sharedApplication().openURL(NSURL(string:"prefs:root=SOMETHING")!)
//    }

}


