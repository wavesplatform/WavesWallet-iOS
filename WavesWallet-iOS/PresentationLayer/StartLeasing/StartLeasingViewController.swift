//
//  StartLeasingViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/27/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback

private enum Constants {
    static let borderWidth: CGFloat = 0.5
    static let assetBgViewCorner: CGFloat = 2

    static let percent50 = 50
    static let percent10 = 10
    static let percent5 = 5
}


final class StartLeasingViewController: UIViewController {
    
    @IBOutlet private weak var labelBalanceTitle: UILabel!
    @IBOutlet private weak var labelAssetName: UILabel!
    @IBOutlet private weak var iconAssetBalance: UIImageView!
    @IBOutlet private weak var labelAssetAmount: UILabel!
    @IBOutlet private weak var iconFavourite: UIImageView!
    @IBOutlet private weak var addressGeneratorView: StartLeasingGeneratorView!
    @IBOutlet private weak var assetBgView: UIView!
    @IBOutlet private weak var amountView: StartLeasingAmountView!
    @IBOutlet private weak var buttonStartLease: HighlightedButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var labelTransactionFee: UILabel!
    
    private var order: StartLeasing.DTO.Order!
    private var isCreatingOrderState: Bool = false
    
    var presenter: StartLeasingPresenterProtocol!
    private let sendEvent: PublishRelay<StartLeasing.Event> = PublishRelay<StartLeasing.Event>()
    
    var availableBalance: Money! {
        didSet {
            
            order = StartLeasing.DTO.Order(address: "", amount: Money(0, availableBalance.decimals))
            
            if !availableBalance.isZero {
                let amountWithFee = availableBalance.amount - order.fee
                availableBalance = Money(amountWithFee < 0 ? 0 : amountWithFee, availableBalance.decimals)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
        createBackButton()
        setupUI()
        setupData()
        setupFeedBack()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
        hideTopBarLine()
    }
 
    @IBAction private func startLeaseTapped(_ sender: Any) {
        sendEvent.accept(.createOrder)
    }
}


//MARK: - FeedBack
private extension StartLeasingViewController {
    
    func setupFeedBack() {
        
        let feedback = bind(self) { owner, state -> Bindings<StartLeasing.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }
        
        presenter.system(feedbacks: [feedback])
    }
    
    func events() -> [Signal<StartLeasing.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<StartLeasing.State>) -> [Disposable] {
        let subscriptionSections = state
            .drive(onNext: { [weak self] state in
                
                guard let strongSelf = self else { return }
                switch state.action {
                case .none:
                    return
                default:
                    break
                }
                
                switch state.action {
                case .showCreatingOrderState:
                    strongSelf.setupCreatingOrderState()
                    
                case .orderDidFailCreate(let error):
                    strongSelf.setupDefaultState()
                    
                case .orderDidCreate:
                    strongSelf.navigationController?.popViewController(animated: true)
                    
                default:
                    break
                }
            })
        
        return [subscriptionSections]
    }
}


//MARK: - Setup
private extension StartLeasingViewController {
    
    var isValidOrder: Bool {
        return order.address.count > 0 &&
            !isNotEnoughAmount &&
            order.amount.amount > 0 &&
            Address.isValidAddress(address: order.address) &&
            !isCreatingOrderState
    }
    
    var isNotEnoughAmount: Bool {
        return order.amount.decimalValue > availableBalance.decimalValue
    }
    
    func setupLocalization() {
        title = Localizable.StartLeasing.Label.startLeasing
        labelBalanceTitle.text = Localizable.StartLeasing.Label.balance
        
        let fee = Money(order.fee, order.amount.decimals)
        labelTransactionFee.text = Localizable.StartLeasing.Label.transactionFee + " " + fee.displayText + " WAVES"
    }
    
    func setupData() {
        
        labelAssetAmount.text = availableBalance.displayTextFull
        
        var inputAmountValues: [StartLeasingAmountView.Input] = []
        
        if !availableBalance.isZero {
            let valuePercent50 = Money(value: availableBalance.decimalValue * Decimal(Constants.percent50) / 100,
                                       availableBalance.decimals)
            
            let valuePercent10 = Money(value: availableBalance.decimalValue * Decimal(Constants.percent10) / 100,
                                       availableBalance.decimals)
            
            let valuePercent5 = Money(value: availableBalance.decimalValue * Decimal(Constants.percent5) / 100,
                                      availableBalance.decimals)
            
            inputAmountValues.append(.init(text: Localizable.DexCreateOrder.Button.useTotalBalanace, value: availableBalance))
            inputAmountValues.append(.init(text: String(Constants.percent50) + "%", value: valuePercent50))
            inputAmountValues.append(.init(text: String(Constants.percent10) + "%", value: valuePercent10))
            inputAmountValues.append(.init(text: String(Constants.percent5) + "%", value: valuePercent5))
        }
     
        amountView.update(with: inputAmountValues)
    }
    
    func setupUI() {
        addressGeneratorView.delegate = self
        amountView.delegate = self
        amountView.maximumFractionDigits = availableBalance.decimals

        iconAssetBalance.layer.cornerRadius = iconAssetBalance.frame.size.width / 2
        iconAssetBalance.layer.borderWidth = Constants.borderWidth
        iconAssetBalance.layer.borderColor = UIColor.overlayDark.cgColor
        
        assetBgView.layer.cornerRadius = Constants.assetBgViewCorner
        assetBgView.layer.borderWidth = Constants.borderWidth
        assetBgView.layer.borderColor = UIColor.overlayDark.cgColor
        
        setupButtonState()
    }
    
    func setupButtonState() {

        buttonStartLease.isUserInteractionEnabled = isValidOrder
        buttonStartLease.backgroundColor = isValidOrder ? .submit400 : .submit200
        
        let buttonTitle = isCreatingOrderState ? "" : Localizable.StartLeasing.Button.startLease
        buttonStartLease.setTitle(buttonTitle, for: .normal)
    }

    func setupDefaultState() {
        isCreatingOrderState = false
        setupButtonState()
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    func setupCreatingOrderState() {
        isCreatingOrderState = true
        setupButtonState()
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }

}

//MARK: - StartLeasingAmountViewDelegate
extension StartLeasingViewController: StartLeasingAmountViewDelegate {
    func startLeasingAmountView(didChangeValue value: Money) {
        order.amount = value
        setupButtonState()
        amountView.showErrorMessage(message: Localizable.StartLeasing.Label.notEnough + " " + "Waves", isShow: isNotEnoughAmount)
        sendEvent.accept(.updateInputOrder(order))
    }
}

//MARK: - StartLeasingGeneratorViewDelegate
extension StartLeasingViewController: StartLeasingGeneratorViewDelegate {

   
    func startLeasingGeneratorViewDidSelectAddressBook() {
        
        let controller = AddressBookModuleBuilder(output: self).build(input: .init(isEditMode: false))
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func startLeasingGeneratorViewDidChangeAddress(_ address: String) {
        order.address = address
        setupButtonState()
        sendEvent.accept(.updateInputOrder(order))
    }
}

//MARK: - AddressBookModuleBuilderOutput
extension StartLeasingViewController: AddressBookModuleOutput {
    func addressBookDidSelectContact(_ contact: DomainLayer.DTO.Contact) {
        order.address = contact.address
        addressGeneratorView.setupText(order.address, animation: false)
        setupButtonState()
        sendEvent.accept(.updateInputOrder(order))
    }
}

//MARK: - UIScrollViewDelegate
extension StartLeasingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
