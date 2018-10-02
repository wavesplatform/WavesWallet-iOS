//
//  UseTouchIDViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import LocalAuthentication
import RxSwift
import RxOptional

protocol UseTouchIDModuleOutput: AnyObject {
    func userSkipRegisterBiometric()
    func userRegisteredBiometric()
}

protocol UseTouchIDModuleInput {
    var passcode: String { get }
    var wallet: DomainLayer.DTO.Wallet { get }
}

final class UseTouchIDViewController: UIViewController {

    @IBOutlet private weak var topLogoOffset: NSLayoutConstraint!
    @IBOutlet private weak var iconTouch: UIImageView!
    @IBOutlet private weak var labelTouchId: UILabel!
    @IBOutlet private weak var labelDescription: UILabel!
    @IBOutlet private weak var buttonUseTouchId: UIButton!
    @IBOutlet private weak var buttonNotNow: UIButton!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!

    weak var moduleOutput: UseTouchIDModuleOutput?
    var input: UseTouchIDModuleInput?

    private var disposeBag: DisposeBag = DisposeBag()
    private var authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSmallNavigationBar()
        navigationItem.backgroundImage = UIImage()
        navigationItem.shadowImage = UIImage()

        setupUI()
        setupButtonUseTouchId()
    }

    private func setupUI() {

        let biometricType = BiometricType.current
        let biometricTitle = biometricType.title ?? ""
        iconTouch.image = biometricType.icon
        labelTouchId.text = Localizable.UseTouchID.Label.Title.text(biometricTitle)
        labelDescription.text = Localizable.UseTouchID.Label.Detail.text(biometricTitle)

        buttonNotNow.setTitle(Localizable.UseTouchID.Button.Notnow.text, for: .normal)

        buttonUseTouchId.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        buttonUseTouchId.setBackgroundImage(UIColor.submit300.image, for: .highlighted)
        buttonUseTouchId.setBackgroundImage(UIColor.submit400.image, for: .normal)
    }

    private func setupButtonUseTouchId() {
        let biometricType = BiometricType.current
        let biometricTitle = biometricType.title ?? ""
        buttonUseTouchId.setTitle(Localizable.UseTouchID.Button.Usebiometric.text(biometricTitle), for: .normal)
    }

    private func startIndicator() -> Void {
        buttonUseTouchId.setTitle(nil, for: .normal)
        buttonUseTouchId.isEnabled = false
        buttonNotNow.isEnabled = false
        indicator.startAnimating()
    }

    private func stopIndicator() -> Void {
        setupButtonUseTouchId()
        buttonUseTouchId.isEnabled = true
        buttonNotNow.isEnabled = true
        indicator.stopAnimating()
    }

    @IBAction func useTouchIdTapped(_ sender: Any) {

        guard let input = input else { return }
        startIndicator()

        authorizationInteractor
        .registerBiometric(wallet: input.wallet, passcode: input.passcode)
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { [weak self] _ in
            self?.stopIndicator()
            self?.moduleOutput?.userRegisteredBiometric()
        }, onError: { [weak self] error in
            self?.stopIndicator()
        })
        .disposed(by: disposeBag)
    }

    @IBAction func notNowTapped(_ sender: Any) {
        moduleOutput?.userSkipRegisterBiometric()
    }
}
