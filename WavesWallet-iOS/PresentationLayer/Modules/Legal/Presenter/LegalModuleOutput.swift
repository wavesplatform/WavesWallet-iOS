//
//  CheckboxModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by Mac on 11/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol LegalModuleOutput: AnyObject {
    
    func legalDidShowTermsController(viewController: UIViewController)

    func legalConfirm()
}
