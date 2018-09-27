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

}

final class UseTouchIDViewController: UIViewController {

    @IBOutlet private weak var topLogoOffset: NSLayoutConstraint!
    @IBOutlet private weak var iconTouch: UIImageView!
    @IBOutlet private weak var labelTouchId: UILabel!
    @IBOutlet private weak var labelDescription: UILabel!
    @IBOutlet private weak var buttonUseTouchId: UIButton!
    @IBOutlet private weak var buttonNotNow: UIButton!

    weak var moduleOutput: UseTouchIDModuleOutput?

    private var disposeBag: DisposeBag = DisposeBag()
    private var authorizationInteractor: AuthorizationInteractorProtocol = FactoryInteractors.instance.authorization

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true

        let biometricType = BiometricType.current
        let biometricTitle = biometricType.title?.uppercased() ?? ""
        iconTouch.image = biometricType.icon

        labelTouchId.text = Localizable.UseTouchID.Label.Title.text(biometricTitle)
        labelDescription.text = Localizable.UseTouchID.Label.Detail.text(biometricTitle)

        buttonNotNow.setTitle(Localizable.UseTouchID.Button.Notnow.text, for: .normal)
        buttonUseTouchId.setTitle(Localizable.UseTouchID.Button.Usebiometric.text(biometricTitle), for: .normal)
        buttonUseTouchId.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        buttonUseTouchId.setBackgroundImage(UIColor.submit400.image, for: .normal)
    }

    @IBAction func useTouchIdTapped(_ sender: Any) {
        authorizationInteractor
            .lastWalletLoggedIn()
            .catchOnNil { Observable.never() }
            .flatMap { wallet -> Observable<Bool> in
                return self.authorizationInteractor.auth(type: .biometric, wallet: wallet)
            }
            .subscribe(weak: self, onNext: { owner, _ in

            })
            .disposed(by: disposeBag)
    }

    
    @IBAction func notNowTapped(_ sender: Any) {

    }
}
