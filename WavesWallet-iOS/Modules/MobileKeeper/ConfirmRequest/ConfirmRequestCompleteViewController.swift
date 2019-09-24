//
//  ConfirmRequestStatusViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 30.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import DomainLayer
import Extensions

final class ConfirmRequestCompleteViewController: UIViewController {
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var buttonOkey: HighlightedButton!
    @IBOutlet private weak var transactionKindView: ConfirmRequestTransactionKindView!
    
    var completedRequest: DomainLayer.DTO.MobileKeeper.CompletedRequest?
    var complitingRequest:  ConfirmRequest.DTO.ComplitingRequest?
    var okButtonDidTap: (() -> Void)? = nil
    private var snackError: String? = nil
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideTopBarLine()
        navigationItem.backgroundImage = UIImage()
        navigationItem.hidesBackButton = true
        setupLocalization()
        
        if let complitingRequest = complitingRequest {
            transactionKindView.update(with: complitingRequest.transaction.transactionKindViewModel)
        }
        
        if let completedRequest = completedRequest {
            
            switch completedRequest.response.kind {
            case .error(let error):
                imageView.image = Images.error80Error500.image
                labelTitle.text = Localizable.Waves.Keeper.Transaction.failed

            case .success(let success):
                imageView.image = Images.userimgDone80Success400.image
                labelTitle.text = Localizable.Waves.Keeper.Transaction.confirmed
                break
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //TODO: Error logic
        if case let .error(model)? = completedRequest?.response.kind {
            switch model {
            case .message(let message, _):
                snackError = showErrorSnack(message)
            default:
                break
            }
            
        }   
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func okeyTapped(_ sender: Any) {
        okButtonDidTap?()
    }
    
    private func setupLocalization() {
        
        //TODO: Localization
        buttonOkey.setTitle(Localizable.Waves.Sendcomplete.Button.okey, for: .normal)
    }
    
    private func showErrorView(with error: DisplayError) {
        
        switch error {
        case .globalError:
            snackError = showWithoutInternetSnack()
            
        case .internetNotWorking:
            snackError = showWithoutInternetSnack()
            
        case .message(let message):
            snackError = showErrorSnack(message)
            
        default:
            snackError = showErrorNotFoundSnack()
            
        }
    }
    
    private func showWithoutInternetSnack() -> String {
        return showWithoutInternetSnack { [weak self] in
            self?.okButtonDidTap?()
        }
    }
    
    private func showErrorSnack(_ message: (String)) -> String {
        return showErrorSnack(title: message, didTap: { [weak self] in
            self?.okButtonDidTap?()
        })
    }
    
    private func showErrorNotFoundSnack() -> String {
        return showErrorNotFoundSnack() { [weak self] in
            self?.okButtonDidTap?()
        }
    }
}

extension ConfirmRequestCompleteViewController: ViewConfiguration {
    
    func update(with model: ConfirmRequestTransactionKindView.Model) {
        transactionKindView.update(with: model)
    }
}
