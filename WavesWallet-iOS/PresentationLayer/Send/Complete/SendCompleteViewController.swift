//
//  SendCompleteViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class SendCompleteViewController: UIViewController {

    struct Input {
        let assetName: String
        let amount: Money
        let address: String
        let amountWithoutFee: Money
    }
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    @IBOutlet private weak var buttonOkey: HighlightedButton!
    @IBOutlet private weak var labelSaveAddress: UILabel!
    @IBOutlet private weak var labelAddress: UILabel!
    @IBOutlet private weak var viewSaveAddress: UIView!
    
    var input: Input!

    override func viewDidLoad() {
        super.viewDidLoad()

        hideTopBarLine()
        navigationItem.backgroundImage = UIImage()
        navigationItem.hidesBackButton = true

        setupLocalization()
        setupData()
    }
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func okeyTapped(_ sender: Any) {
        
        if let assetVc = navigationController?.viewControllers.first(where: {$0.classForCoder == AssetViewController.classForCoder()}) {
            navigationController?.popToViewController(assetVc, animated: true)
        }
        else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction private func addContact(_ sender: Any) {
    
        let vc = AddAddressBookModuleBuilder(output: self).build(input: .init(contact: nil, address: input.address))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupData() {
        
        //TODO: here can be address from coinomat and it's different that user input in recipient
        labelAddress.text = input.address
        let amountText = input.amountWithoutFee.displayText + " " + input.assetName
        
        labelSubtitle.text = Localizable.SendComplete.Label.youHaveSent + " " + amountText
        
        let addressBook: AddressBookInteractorProtocol = AddressBookInteractor()
        addressBook.users().subscribe(onNext: { [weak self] contacts in
            
            guard let strongSelf = self else { return }
            let isExistContact = contacts.filter({$0.address == strongSelf.input.address }).count > 0
            strongSelf.viewSaveAddress.isHidden = isExistContact
            
        }).dispose()
    }
    
    private func setupLocalization() {
        
        labelSaveAddress.text = Localizable.SendComplete.Label.saveThisAddress
        buttonOkey.setTitle(Localizable.SendComplete.Button.okey, for: .normal)
        labelTitle.text = Localizable.SendComplete.Label.transactionIsOnWay
    }
}

//MARK: - AddAddressBookModuleOutput

extension SendCompleteViewController: AddAddressBookModuleOutput {
    func addAddressBookDidCreate(contact: DomainLayer.DTO.Contact) {
        viewSaveAddress.isHidden = true
    }
}
