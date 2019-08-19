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
            let body = UIDevice.current.deviceDescription()
            guard let encodedParams = "body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
            guard let url = URL.init(string: "mailto:\(email)?\(encodedParams)") else { return }
            UIApplication.shared.openURLAsync(url)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        removeFromParentCoordinator()
    }
}


