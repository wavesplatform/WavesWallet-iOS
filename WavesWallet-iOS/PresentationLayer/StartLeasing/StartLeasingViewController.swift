//
//  StartLeasingViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/27/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let borderWidth: CGFloat = 0.5
    static let assetBgViewCorner: CGFloat = 2

    static let percent50 = 50
    static let percent10 = 10
    static let percent5 = 5
}


final class StartLeasingViewController: UIViewController {

    struct Input {
        let asset: WalletTypes.DTO.Asset
        let balance: WalletTypes.DTO.Leasing.Balance
    }
    
    @IBOutlet private weak var labelBalanceTitle: UILabel!
    @IBOutlet private weak var labelAssetName: UILabel!
    @IBOutlet private weak var iconAssetBalance: UIImageView!
    @IBOutlet private weak var labelAssetAmount: UILabel!
    @IBOutlet private weak var iconFavourite: UIImageView!
    @IBOutlet private weak var addressGeneratorView: StartLeasingGeneratorView!
    @IBOutlet private weak var assetBgView: UIView!
    @IBOutlet private weak var amountView: StartLeasingAmountView!
    
    private var isValidLease: Bool {
        return false
    }
    
    private let availableAmountAssetBalance = Money(value: 113.34, 8)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocalization()
        createBackButton()
        setupUI()
        setupData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
        hideTopBarLine()
    }
}

//MARK: - Setup
private extension StartLeasingViewController {
    func setupLocalization() {
        title = Localizable.StartLeasing.Label.startLeasing
        labelBalanceTitle.text = Localizable.StartLeasing.Label.balance
    }
    
    func setupData() {
        
        var inputAmountValues: [StartLeasingAmountView.Input] = []
        
        let valuePercent50 = Money(value: availableAmountAssetBalance.decimalValue * Decimal(Constants.percent50) / 100,
                                   availableAmountAssetBalance.decimals)
        
        let valuePercent10 = Money(value: availableAmountAssetBalance.decimalValue * Decimal(Constants.percent10) / 100,
                                   availableAmountAssetBalance.decimals)
        
        let valuePercent5 = Money(value: availableAmountAssetBalance.decimalValue * Decimal(Constants.percent5) / 100,
                                  availableAmountAssetBalance.decimals)
        
        inputAmountValues.append(.init(text: Localizable.DexCreateOrder.Button.useTotalBalanace, value: availableAmountAssetBalance))
        inputAmountValues.append(.init(text: String(Constants.percent50) + "%", value: valuePercent50))
        inputAmountValues.append(.init(text: String(Constants.percent10) + "%", value: valuePercent10))
        inputAmountValues.append(.init(text: String(Constants.percent5) + "%", value: valuePercent5))
        
        amountView.update(with: inputAmountValues)
        
        let list = AddressBookRepository().list()
        list.subscribe(onNext: { (contacts) in
            self.addressGeneratorView.update(with: contacts)
        }).dispose()
    }
    
    func setupUI() {
        addressGeneratorView.delegate = self
        amountView.delegate = self
        amountView.maximumFractionDigits = availableAmountAssetBalance.decimals

        iconAssetBalance.layer.cornerRadius = iconAssetBalance.frame.size.width / 2
        iconAssetBalance.layer.borderWidth = Constants.borderWidth
        iconAssetBalance.layer.borderColor = UIColor.overlayDark.cgColor
        
        assetBgView.layer.cornerRadius = Constants.assetBgViewCorner
        assetBgView.layer.borderWidth = Constants.borderWidth
        assetBgView.layer.borderColor = UIColor.overlayDark.cgColor
        
    }
}

//MARK: - StartLeasingAmountViewDelegate
extension StartLeasingViewController: StartLeasingAmountViewDelegate {
    func startLeasingAmountView(didChangeValue value: Money) {
        print(value)
    }
}

//MARK: - StartLeasingGeneratorViewDelegate
extension StartLeasingViewController: StartLeasingGeneratorViewDelegate {

    func startLeasingGeneratorViewDidSelect(_ contact: DomainLayer.DTO.Contact) {

    }
    
    func startLeasingGeneratorViewDidSelectAddressBook() {
        
        let controller = AddressBookModuleBuilder(output: self).build(input: .init(isEditMode: false))
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func startLeasingGeneratorViewDidChangeAddress(_ address: String) {
        
    }
}

//MARK: - AddressBookModuleBuilderOutput
extension StartLeasingViewController: AddressBookModuleOutput {
    func addressBookDidSelectContact(_ contact: DomainLayer.DTO.Contact) {
        addressGeneratorView.setupText(contact.name, animation: false)
    }
}

//MARK: - UIScrollViewDelegate
extension StartLeasingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}
