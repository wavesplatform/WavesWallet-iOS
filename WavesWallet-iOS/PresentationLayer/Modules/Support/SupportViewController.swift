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

protocol SupportViewControllerDelegate: AnyObject {
    func closeSupportView(isTestNet: Bool)
    func relaunchApp()
}

final class SupportViewController: UIViewController {
    @IBOutlet private var versionLabel: UILabel!
    @IBOutlet private var buildVersionLabel: UILabel!
    @IBOutlet private var testNetSwitch: UISwitch!
    weak var delegate: SupportViewControllerDelegate?
    private let auth: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization
    private let transactions: TransactionsInteractorProtocol = FactoryInteractors.instance.transactions

    override func viewDidLoad() {
        super.viewDidLoad()
        let on = Environment.isTestNet
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

    static let image = "test"

    private let popoverViewControllerTransitioning = ModalViewControllerTransitioning {

    }

    let accountBalance: AccountBalanceInteractorProtocol = FactoryInteractors.instance.accountBalance

    @IBAction private func actionCrash(_ sender: Any) {

        let wallet = DomainLayer.DTO.Wallet(name: "Test",
                                            address: "3P5r1EXZwxJ21f3T3zvjx61RtY52QV4fb18",
                                            publicKey: "27C8ksVhVFUXyngF1F8TfyCGLmkDMsm2QuTv4VvhBpJU",
                                            isLoggedIn: true,
                                            isBackedUp: false, hasBiometricEntrance: false, isAlreadyShowLegalDisplay: false, id: "test")

        let walletSeed = DomainLayer.DTO.WalletSeed.init(publicKey: "27C8ksVhVFUXyngF1F8TfyCGLmkDMsm2QuTv4VvhBpJU",
                                                         seed: "cousin define prevent proof deal absurd purpose swap original tired ivory spoil reflect simple oval",
                                                         address: "3P5r1EXZwxJ21f3T3zvjx61RtY52QV4fb18")

        let signedWallet = DomainLayer.DTO.SignedWallet(wallet: wallet, seed: walletSeed)

        accountBalance
            .balance(by: "8gQ9X6vgg7dXD1GkvqjhnANM4KDdA24ARpTKzuLJ9ZBm",
                               wallet: signedWallet)
            .subscribe({ (event) in
                print(event)
            })
    }


    @IBAction func actionClean(_ sender: Any) {
        let auth = FactoryInteractors.instance.authorization
        auth.authorizedWallet().flatMap { (wallet) -> Observable<Bool> in
            let realm = try? WalletRealmFactory.realm(accountAddress: wallet.address)
            try? realm?.write {
                realm?.deleteAll()
            }
            return Observable.just(true)
        }.subscribe().dispose()
    }

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
