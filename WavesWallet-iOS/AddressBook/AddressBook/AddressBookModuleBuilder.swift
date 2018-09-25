//
//  AddressBookViewControllerBuilder.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

struct AddressBookModuleBuilder: ModuleBuilderOutput {
    
    var output: AddressBookModuleOutput?
    
    struct Input {
        let isEditMode: Bool
    }
    
    func build(input: Input) -> UIViewController {
        
        let interactor: AddressBookInteractorProtocol = AddressBookInteractorMock()
        
        var presenter: AddressBookPresenterProtocol = AddressBookPresenter()
        presenter.interactor = interactor

        let vc = StoryboardScene.AddressBook.addressBookViewController.instantiate()
        vc.isEditMode = input.isEditMode
        vc.delegate = output
        vc.presenter = presenter
        
        return vc
    }

}
