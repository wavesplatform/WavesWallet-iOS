//
//  SupportViewController.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 02/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import Crashlytics
import RxSwift
import WavesSDKExtensions
import Extensions
import DomainLayer

protocol SupportViewControllerDelegate: AnyObject {
    func closeSupportView(isTestNet: Bool)
    func relaunchApp()
}

final class SupportViewController: UIViewController {
    @IBOutlet private var versionLabel: UILabel!
    @IBOutlet private var buildVersionLabel: UILabel!
    @IBOutlet private var testNetSwitch: UISwitch!
    @IBOutlet private weak var enableStageSwitch: UISwitch!
    
    @IBOutlet private weak var enableNotificationsSettingDevSwitch: UISwitch!
    
    
    weak var delegate: SupportViewControllerDelegate?
    private let auth: AuthorizationUseCaseProtocol = UseCasesFactory.instance.authorization
    private let transactions: TransactionsUseCaseProtocol = UseCasesFactory.instance.transactions
    
    private let enviroment: EnvironmentRepositoryProtocol = UseCasesFactory.instance.repositories.environmentRepository
    private let assets = UseCasesFactory.instance.repositories.assetsRepositoryRemote
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let accountBalance = UseCasesFactory.instance.accountBalance

    override func viewDidLoad() {
        super.viewDidLoad()

        testNetSwitch.setOn(WalletEnvironment.isTestNet, animated: true)
        versionLabel.text = version()
        buildVersionLabel.text = buildVersion()
        enableStageSwitch.isOn = ApplicationDebugSettings.isEnableStage
        enableNotificationsSettingDevSwitch.isOn = ApplicationDebugSettings.isEnableNotificationsSettingDev
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: Images.topbarLogout.image, style: .done, target: self, action: #selector(actionBack))
    }

    @IBAction private func actionBack() {
        delegate?.closeSupportView(isTestNet: testNetSwitch.isOn)
    }

    @IBAction func actionTestNetSwitch(sender: Any) {}

    @IBAction private func switchEnableStageChange(_ sender: Any) {
        ApplicationDebugSettings.setupIsEnableStage(isEnable: enableStageSwitch.isOn)
    }
    
    @IBAction private func actionCrash(_ sender: Any) {
        
    }
    
    @IBAction private func actionAnyButton(_ sender: Any) {
        
            
    }


    @IBAction func actionClean(_ sender: Any) {}

    @IBAction func actionShowErrorSnack(_ sender: Any) {

        showErrorSnack(title: "Какая-нибудь лайтовая ошибка") {
            self.showSuccesSnack(title: "Тебе показалось.")
        }
    }

    @IBAction func actionShowWithoutInternetSnack(_ sender: Any) {
        showWithoutInternetSnack() {
            print("Привет Вася.")
        }
    }

    @IBAction func actionShowSuccessSnack(_ sender: Any) {
        self.showSuccesSnack(title: "Успешный вход/успешная операция (≚ᄌ≚)ℒℴѵℯ❤")
    }

    @IBAction func actionShowSeedSnack(_ sender: Any) {

        showWarningSnack(title: "Save your backup phrase (SEED)", subtitle: "Store your SEED safely, it is the only way to restore your wallet", didTap: {
            print("└(=^‥^=)┘")
        }) {
            print("ฅ(⌯͒•̩̩̩́ ˑ̫ •̩̩̩̀⌯͒)ฅ")
        }
    }
}


extension SupportViewController {
    
}

extension SupportViewController {
    
    private func version() -> String {
        let dictionary = Bundle.main.infoDictionary
        let version = dictionary?["CFBundleShortVersionString"] as? String
        return version ?? ""
    }
    
    private func buildVersion() -> String {
        let dictionary = Bundle.main.infoDictionary
        let build = dictionary?["CFBundleVersion"] as? String
        return build ?? ""
    }
}
