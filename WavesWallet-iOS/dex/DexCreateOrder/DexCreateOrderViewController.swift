//
//  DexSellBuyViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/8/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexCreateOrderViewController: UIViewController {

    var input: DexCreateOrder.DTO.Input!
    
    @IBOutlet weak var typeView: DexCreateOrderTypeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTypeView()
    }
}

//MARK: - DexCreateOrderTypeViewDelegate
extension DexCreateOrderViewController: DexCreateOrderTypeViewDelegate {
    
    func dexCreateOrderDidChangeType(_ type: DexCreateOrder.DTO.OrderType) {
        
    }
}

//MARK: - Setup

private extension DexCreateOrderViewController {
    func setupTypeView() {
        typeView.type = input.type
        typeView.delegate = self
    }
}
