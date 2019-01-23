//
//  CreateNewAliasViewController.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 28/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift


protocol AliasWithoutViewControllerDelegate: AnyObject {
    func aliasWithoutUserTapCreateNewAlias()
}

final class AliasWithoutViewController: UIViewController, Localization {
    weak var delegate: AliasWithoutViewControllerDelegate?

    @IBOutlet private var createButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var secondSubtitleLabel: UILabel!    
    @IBOutlet private var transactionFeeView: TransactionFeeView!

    private let disposeBag: DisposeBag = DisposeBag()
    private let transactionsInteractor = FactoryInteractors.instance.transactions
    private let authorizationInteractor = FactoryInteractors.instance.authorization
    private var errorSnackKey: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        createButton.setBackgroundImage(UIColor.submit200.image, for: .disabled)
        createButton.setBackgroundImage(UIColor.submit400.image, for: .normal)
        setupLocalization()
        loadingFee()
    }

    private func loadingFee() {

        self.startLoadingFee()
        return self
            .authorizationInteractor
            .authorizedWallet()
            .flatMap({ [weak self] (wallet) -> Observable<Money> in
                guard let owner = self else { return Observable.never() }
                return owner.transactionsInteractor.calculateFee(by: .createAlias, accountAddress: wallet.address)
            })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (money) in
                self?.setFee(money)
            }, onError: { [weak self] (error) in
                self?.handlerError(error)
            })
            .disposed(by: disposeBag)
    }

    private func startLoadingFee() {
        transactionFeeView.showLoadingState()
    }

    private func setFee(_ fee: Money) {
        transactionFeeView.hideLoadingState()
        transactionFeeView.update(with: fee)

        if let errorSnackKey = errorSnackKey {
            hideSnack(key: errorSnackKey)
        }
    }

    private func handlerError(_ error: Error) {

        let displayError = DisplayError(error: error)

        switch displayError {
        case .globalError(let isInternetNotWorking):

            if isInternetNotWorking {
                errorSnackKey = showWithoutInternetSnack { [weak self] in
                    self?.loadingFee()
                }
            } else {
                errorSnackKey = showErrorNotFoundSnack(didTap: { [weak self] in
                    self?.loadingFee()
                })
            }
        case .internetNotWorking:
            errorSnackKey = showWithoutInternetSnack { [weak self] in
                self?.loadingFee()
            }

        case .message(let text):
            errorSnackKey = showMessageSnack(title: text, didTap: { [weak self] in
                self?.loadingFee()
            })

        case .notFound, .scriptError:
            errorSnackKey = showErrorNotFoundSnack(didTap: { [weak self] in
                self?.loadingFee()
            })
        }
    }   

    @IBAction func handlerTapCreateButton(sender: Any) {
        delegate?.aliasWithoutUserTapCreateNewAlias()
    }

    func setupLocalization() {
        createButton.setTitle(Localizable.Waves.Aliaseswithout.View.Info.Button.create, for: .normal)
        titleLabel.text = Localizable.Waves.Aliaseswithout.View.Info.Label.title
        subtitleLabel.text = Localizable.Waves.Aliaseswithout.View.Info.Label.subtitle
        secondSubtitleLabel.text = Localizable.Waves.Aliaseswithout.View.Info.Label.secondsubtitle
    }
}
