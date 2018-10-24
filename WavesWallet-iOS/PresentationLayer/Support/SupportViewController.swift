//
//  SupportViewController.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 02/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol SupportViewControllerDelegate: AnyObject {
    func closeSupportView(isTestNet: Bool)
}

final class SupportViewController: UIViewController {
    @IBOutlet private var versionLabel: UILabel!
    @IBOutlet private var buildVersionLabel: UILabel!
    @IBOutlet private var testNetSwitch: UISwitch!
    weak var delegate: SupportViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let on = Environments.isTestNet
        testNetSwitch.setOn(on, animated: true)
        versionLabel.text = version()
        buildVersionLabel.text = buildVersion()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.topbarLogout.image, style: .done, target: self, action: #selector(actionBack))
    }

    @IBAction private func actionBack() {
        delegate?.closeSupportView(isTestNet: testNetSwitch.isOn)
    }

    @IBAction func actionTestNetSwitch(sender: Any) {
        
    }

    private func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        return version
    }

    private func buildVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let build = dictionary["CFBundleVersion"] as! String
        return build
    }
}

