//
//  ReceiveAnimationGenerateViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxFeedback

private enum Constants {
    static let simulatingCryptocurrencyTime: TimeInterval = 1
}

final class ReceiveGenerateAddressViewController: UIViewController {

    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var labelGenerate: UILabel!
    
    var input: ReceiveGenerate.DTO.GenerateType!
  
    var presenter: ReceiveGeneratePresenterProtocol!
    private let sendEvent: PublishRelay<ReceiveGenerate.Event> = PublishRelay<ReceiveGenerate.Event>()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
        viewContainer.addTableCellShadowStyle()
        addBgBlueImage()
        setupLocalication()
        setupFeedBack()
        acceptGeneratingAddress()
    }
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.backgroundImage = UIImage()
        hideTopBarLine()
        navigationItem.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationItem.backgroundImage = nil
        showTopBarLine()
        navigationItem.titleTextAttributes = nil
    }
    
    private func acceptGeneratingAddress() {
        
        guard let type = input else { return }
        switch type {
        case .cryproCurrency(let displayInfo):
            showCryptocurrencyAddressInfo(displayInfo)
            
        default:
            break
        }
    }
    
    private func setupLocalication() {
        
        labelGenerate.text = Localizable.ReceiveGenerate.Label.generate
     
        guard let type = input else { return }
        
        switch type {
        case .cryproCurrency(let info):
            title = Localizable.ReceiveGenerate.Label.yourAddress(info.assetName)
            
        case .invoice(let info):
            guard let name = info.balanceAsset.asset?.displayName else { return }
            title = Localizable.ReceiveGenerate.Label.yourAddress(name)
        }
    }
    
    private func showCryptocurrencyAddressInfo(_ info: ReceiveCryptocurrency.DTO.DisplayInfo) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.simulatingCryptocurrencyTime) {
            print("showCryptocurrencyAddressInfo")
        }
    }
    
    private func showInvoceAddressInfo(_ info: ReceiveInvoive.DTO.DisplayInfo) {
        print("showInvoceAddressInfo")
    }
}


//MARK: - FeedBack
private extension ReceiveGenerateAddressViewController {
    
    func setupFeedBack() {
        
        let feedback = bind(self) { owner, state -> Bindings<ReceiveGenerate.Event> in
            return Bindings(subscriptions: owner.subscriptions(state: state), events: owner.events())
        }    
        
        var invoiceGenerateInfo: ReceiveInvoive.DTO.GenerateInfo? {
            guard let type = input else { return nil }
            switch type {
            case .invoice(let info):
                return info
                
            default:
                return nil
            }
        }
        
        presenter.system(feedbacks: [feedback], invoiceGenerateInfo: invoiceGenerateInfo)
    }
    
    func events() -> [Signal<ReceiveGenerate.Event>] {
        return [sendEvent.asSignal()]
    }
    
    func subscriptions(state: Driver<ReceiveGenerate.State>) -> [Disposable] {
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

                case .invoiceDidCreate(let info):
                    strongSelf.showInvoceAddressInfo(info)
                    
                case .invoiceDidFailCreate(let error):
                    strongSelf.navigationController?.popViewController(animated: true)
                    
                default:
                    break
                }
            })
        
        return [subscriptionSections]
    }
}
