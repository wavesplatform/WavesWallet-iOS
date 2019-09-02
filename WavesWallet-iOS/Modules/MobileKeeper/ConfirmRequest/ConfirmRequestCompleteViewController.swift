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
            //TODO: Localization
            
            switch completedRequest.response {
            case .error(let error):
                imageView.image = Images.info18Error500.image
                labelTitle.text = "Ошибка Ошибка"
            case .success(let success):
                imageView.image = Images.userimgDone80Success400.image
                labelTitle.text = "Ок"
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
}

extension ConfirmRequestCompleteViewController: ViewConfiguration {
    
    func update(with model: ConfirmRequestTransactionKindView.Model) {
        transactionKindView.update(with: model)
    }
}
