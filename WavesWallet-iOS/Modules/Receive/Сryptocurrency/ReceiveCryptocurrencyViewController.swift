//
//  ReceiveСryptocurrencyViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import DomainLayer
import RxCocoa
import RxFeedback
import RxSwift
import UIKit

final class ReceiveCryptocurrencyViewController: UIViewController {
    @IBOutlet private weak var assetView: AssetSelectView!

    @IBOutlet private weak var viewWarning: UIView!

    @IBOutlet private weak var labelTitleMinimumAmount: UILabel!
    @IBOutlet private weak var labelWarningMinimumAmount: UILabel!
    @IBOutlet private weak var labelTitleSendOnlyDeposit: UILabel!
    @IBOutlet private weak var labelWarningSendOnlyDeposit: UILabel!

    @IBOutlet private weak var labelTitleSendOnlyDepositBottom: NSLayoutConstraint!

    @IBOutlet private weak var buttonCotinue: HighlightedButton!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var coinomatErrorView: CoinomatServiceErrorView!

    @IBOutlet private weak var warningContainersBottom: NSLayoutConstraint!

    private var receiveAddressCoordinator: Coordinator?

    private var selectedAsset: DomainLayer.DTO.SmartAssetBalance?
    private var displayInfo: ReceiveCryptocurrency.DTO.DisplayInfo?

    private let sendEvent: PublishRelay<ReceiveCryptocurrency.Event> = PublishRelay<ReceiveCryptocurrency.Event>()
    var presenter: ReceiveCryptocurrencyPresenterProtocol!

    var input: AssetList.DTO.Input!

    override func viewDidLoad() {
        super.viewDidLoad()

        assetView.delegate = self
        setupLocalization()
        setupButtonState()
        setupFeedBack()
        viewWarning.isHidden = true

        if let asset = input.selectedAsset {
            assetView.isSelectedAssetMode = false
            setupAssetInfo(asset)
        }
    }

    @IBAction private func continueTapped(_: Any) {
        guard let info = displayInfo else { return }

        guard let navigationController = self.navigationController else { return }
        let router = NavigationRouter(navigationController: navigationController)

        receiveAddressCoordinator = ReceiveAddressCoordinator(navigationRouter: router,
                                                              generateType: .cryptoCurrency(info))

        receiveAddressCoordinator?.start()

        UseCasesFactory.instance.analyticManager.trackEvent(.receive(.receiveTap(assetName: info.asset.displayName)))
    }

    private func setupAssetInfo(_ asset: DomainLayer.DTO.SmartAssetBalance) {
        selectedAsset = asset
        assetView.update(with: .init(assetBalance: asset,
                                     isOnlyBlockMode: input.selectedAsset != nil,
                                     hideAmount: true))
        setupLoadingState()
        setupButtonState()

        let asset = asset.asset
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.sendEvent.accept(.generateAddress(asset: asset))
        }
    }
}

// MARK: - FeedBack

private extension ReceiveCryptocurrencyViewController {
    func setupFeedBack() {
        let feedback = bind(self) { owner, state -> Bindings<ReceiveCryptocurrency.Event> in
            Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }

        presenter.system(feedbacks: [feedback])
    }

    func events() -> [Signal<ReceiveCryptocurrency.Event>] {
        return [sendEvent.asSignal()]
    }

    func subscriptions(state: Driver<ReceiveCryptocurrency.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in

                self?.displayInfo = state.displayInfo

                guard let self = self else { return }
                switch state.action {
                case .none:
                    return
                default:
                    break
                }

                switch state.action {
                case .addressDidGenerate:
                    self.setupWarning()
                    self.setupButtonState()

                case let .addressDidFailGenerate(error):

                    switch error {
                    case .internetNotWorking:
                        self.coinomatErrorView.isHidden = true
                        self.showNetworkErrorSnack(error: error,
                                                   customTitle: Localizable.Waves.Receive.Error.serviceUnavailable)

                    default:
                        self.coinomatErrorView.isHidden = false
                    }

                    self.activityIndicatorView.stopAnimating()

                default:
                    break
                }
            })

        return [subscriptionSections]
    }
}

// MARK: - SetupUI

private extension ReceiveCryptocurrencyViewController {
    private enum Constants {
        /// Константа, регулирующая расстояние между контейнерами предупреждений (необходима, чтоб ее восстанавливать после того как был показан 1 контейнер а после снова 2)
        static let warningContainersBottomConstant: CGFloat = 14
        /// Константа, регулирующая расстояние между лейблами верхнего контейнера (см. описание выше)
        static let labelTitleSendOnlyDepositBottomConstant: CGFloat = 6
    }

    func setupButtonState() {
        let canContinueAction = selectedAsset != nil && displayInfo != nil

        buttonCotinue.isUserInteractionEnabled = canContinueAction
        buttonCotinue.backgroundColor = canContinueAction ? .submit400 : .submit200
    }

    func setupLoadingState() {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        viewWarning.isHidden = true
        coinomatErrorView.isHidden = true
    }

    func setupWarning() {
        guard let info = displayInfo else { return }

        labelTitleSendOnlyDepositBottom.constant = Constants.labelTitleSendOnlyDepositBottomConstant

        warningContainersBottom.constant = Constants.warningContainersBottomConstant

        activityIndicatorView.stopAnimating()
        viewWarning.isHidden = false
        coinomatErrorView.isHidden = true

        let assetGatewayId = info.asset.gatewayId

        if let assetInfo = info.generalAssets.first(where: { $0.gatewayId == assetGatewayId }) {
            let displayName = info.asset.displayName

            let displayMin = info.minAmount.displayText + " " + displayName
            let displayMax = info.maxAmount.map { $0.displayText + " " + displayName }

            let minMaxAmountOfDeposite = displayMax.map {
                Localizable.Waves.Receivecryptocurrency.Label.minAndMaxAmountOfDeposit(displayMin, $0)
            } ?? Localizable.Waves.Receivecryptocurrency.Label.minumumAmountOfDeposit(displayMin)

                switch assetInfo.gatewayId {
                case "BTC", "LTC", "BCH", "DASH", "Zech", "BSV", "ERGO", "Vostok", "WEST":
                    labelTitleSendOnlyDeposit.text = Localizable.Waves.Receivecryptocurrency.Label
                        .sendOnlyOnThisDeposit(displayName)
                    labelWarningSendOnlyDeposit.text = Localizable.Waves.Receivecryptocurrency.Label
                        .warningSendOnlyOnThisDeposit

                    labelTitleMinimumAmount.text = minMaxAmountOfDeposite
                    labelWarningMinimumAmount.text = Localizable.Waves.Receivecryptocurrency.Label
                        .warningMinimumAmountOfDeposit(displayMin)

                case "ETH":
                    labelTitleSendOnlyDeposit.text = Localizable.Waves.Receivecryptocurrency.Label.Warningsmartcontracts
                        .title(info.asset.displayName, info.asset.displayName)
                    labelWarningSendOnlyDeposit.text = Localizable.Waves.Receivecryptocurrency.Label.Warningsmartcontracts
                        .subtitle(info.asset.displayName)

                    labelTitleMinimumAmount.text = minMaxAmountOfDeposite
                    labelWarningMinimumAmount.text = Localizable.Waves.Receivecryptocurrency.Label
                        .warningMinimumAmountOfDeposit(displayMin)
                case "USDT":
                    labelTitleSendOnlyDeposit.text = Localizable.Waves.Receivecryptocurrency.Label
                        .usdtWarningTitleDeposite(displayName, displayName, displayName)
                    labelWarningSendOnlyDeposit.text = Localizable.Waves.Receivecryptocurrency.Label
                        .usdtWarningDetailsDeposite(assetInfo.displayName)

                    labelTitleMinimumAmount.text = minMaxAmountOfDeposite
                    labelWarningMinimumAmount.text = Localizable.Waves.Receivecryptocurrency.Label
                        .warningMinimumAmountOfDeposit(displayMin)

                case "BNT":
                    labelTitleSendOnlyDeposit.text = Localizable.Waves.Receivecryptocurrency.Label
                        .usdtWarningTitleDeposite(displayName, displayName, displayName)
                    labelWarningSendOnlyDeposit.text = Localizable.Waves.Receivecryptocurrency.Label
                        .usdtWarningDetailsDeposite(assetInfo.displayName)

                    labelTitleMinimumAmount.text = minMaxAmountOfDeposite
                    labelWarningMinimumAmount.text = Localizable.Waves.Receivecryptocurrency.Label
                        .warningMinimumAmountOfDeposit(displayMin)

                case "XMR":
                    labelTitleSendOnlyDeposit.text = Localizable.Waves.Receivecryptocurrency.Label
                    .sendOnlyOnThisDeposit(displayName)

                let sendOnlyDeposit = Localizable.Waves.Receivecryptocurrency.Label.paymentIdIsNotRequired +
                    "\n" +
                    Localizable.Waves.Receivecryptocurrency.Label.warningSendOnlyOnThisDeposit

                labelWarningSendOnlyDeposit.text = sendOnlyDeposit

                labelTitleMinimumAmount.text = minMaxAmountOfDeposite
                labelWarningMinimumAmount.text = Localizable.Waves.Receivecryptocurrency.Label
                    .warningMinimumAmountOfDeposit(displayMin)
            default:
                viewWarning.isHidden = true
                labelTitleSendOnlyDeposit.text = ""
                labelWarningSendOnlyDeposit.text = ""
                labelTitleMinimumAmount.text = ""
                labelWarningMinimumAmount.text = ""
            }
        }
    }

    func setupLocalization() {
        buttonCotinue.setTitle(Localizable.Waves.Receive.Button.continue, for: .normal)
    }
}

// MARK: - ReceiveAssetViewDelegate

extension ReceiveCryptocurrencyViewController: AssetSelectViewDelegate {
    func assetViewDidTapChangeAsset() {
        let assetInput = AssetList.DTO.Input(filters: input.filters,
                                             selectedAsset: selectedAsset,
                                             showAllList: input.showAllList)
        let vc = AssetListModuleBuilder(output: self).build(input: assetInput)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ReceiveCryptocurrencyViewController: AssetListModuleOutput {
    func assetListDidSelectAsset(_ asset: DomainLayer.DTO.SmartAssetBalance) {
        displayInfo = nil
        setupAssetInfo(asset)
    }
}
