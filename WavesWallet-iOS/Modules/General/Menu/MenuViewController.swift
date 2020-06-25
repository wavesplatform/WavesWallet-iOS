//
//  MenuViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/28/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import DomainLayer
import Extensions

protocol MenuViewControllerDelegate: AnyObject {
    func menuViewControllerDidTapWavesLogo()
}

class MenuViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var communitiesLabel: UILabel!
    @IBOutlet weak var faqButton: UIButton!
    @IBOutlet weak var termAndConditionsButton: UIButton!
    @IBOutlet weak var supportWavesplatformButton: UIButton!
    @IBOutlet weak var wavesLogoImageView: UIImageView!
    
    private lazy var tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handlerTapWavesLogo))
    
    weak var delegate: MenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tapGesture.numberOfTapsRequired = 5
        wavesLogoImageView.addGestureRecognizer(tapGesture)
        setupLocalization()

        NotificationCenter.default.addObserver(self, selector: #selector(changedLanguage), name: .changedLanguage, object: nil)
    }

    @objc func handlerTapWavesLogo() {
        self.delegate?.menuViewControllerDidTapWavesLogo()
    }
    
    @objc func changedLanguage() {
        setupLocalization()
    }
        
    @IBAction func telegramTapped(_ sender: Any) {
        
        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.menu(.wavesMenuTelegram))
        
        if let url = URL(string: UIGlobalConstants.URL.telegram) {
            UIApplication.shared.openURLAsync(url)
        }
    }
    
    @IBAction func twitterTapped(_ sender: Any) {
        
        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.menu(.wavesMenuTwitter))
        
        if let url = URL(string: UIGlobalConstants.URL.twitter) {
            UIApplication.shared.openURLAsync(url)
        }
    }
    
    @IBAction func mediumTapped(_ sender: Any) {
        
        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.menu(.wavesMenuMedium))
        
        if let url = URL(string: UIGlobalConstants.URL.medium) {
            UIApplication.shared.openURLAsync(url)
        }
    }
    
    @IBAction func faqTapped(_ sender: Any) {
         
         UseCasesFactory
             .instance
             .analyticManager
             .trackEvent(.menu(.wavesMenuFAQ))
         
         if let url = URL(string: UIGlobalConstants.URL.medium) {
             BrowserViewController.openURL(url)
         }
     }
    
    @IBAction func termAndConditionsTapped(_ sender: Any) {
        
        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.menu(.wavesMenuTermsAndConditions))
                
        if let url = URL(string: UIGlobalConstants.URL.termsOfConditions) {
            BrowserViewController.openURL(url)
        }
    }

    @IBAction func supportWavesplatformTapped(_ sender: Any) {
        
        UseCasesFactory
            .instance
            .analyticManager
            .trackEvent(.menu(.wavesMenuSupport))
        
        if let url = URL(string: UIGlobalConstants.URL.supportEn) {
            BrowserViewController.openURL(url)
        }
    }
}

extension MenuViewController: Localization {
    func setupLocalization() {

        descriptionLabel.text = Localizable.Waves.Menu.Label.description
        communitiesLabel.text = Localizable.Waves.Menu.Label.communities
        faqButton.setTitle(Localizable.Waves.Menu.Button.faq, for: .normal)
        termAndConditionsButton.setTitle(Localizable.Waves.Menu.Button.termsandconditions, for: .normal)
        supportWavesplatformButton.setTitle(Localizable.Waves.Menu.Button.supportwavesplatform, for: .normal)
    }
}
