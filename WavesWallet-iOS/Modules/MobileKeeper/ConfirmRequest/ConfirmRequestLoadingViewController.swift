//
//  SendLoadingViewController.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 30.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import RxSwift
import DomainLayer

final class ConfirmRequestLoadingViewController: UIViewController {
    
    @IBOutlet private weak var labelSending: UILabel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Localization
        labelSending.text = Localizable.Waves.Sendloading.Label.sending
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTopBarLine()
        navigationItem.backgroundImage = UIImage()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

