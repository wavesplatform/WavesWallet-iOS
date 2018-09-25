//
//  AddAddressBookModuleBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct AddAddressBookModuleBuilder: ModuleBuilder {
        
    func build(input: DomainLayer.DTO.User?) -> UIViewController {
        
        let vc = StoryboardScene.AddressBook.addAddressBookViewController.instantiate()
        vc.user = input
        return vc
    }
}
