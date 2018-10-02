//
//  ReceiveContainerViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class ReceiveContainerViewController: UIViewController {

    private var viewControllers: [UIViewController] = []
    
    @IBOutlet private weak var segmentedControl: SegmentedControl!
    
    private var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Localizable.Receive.Label.receive
        createBackButton()
        
        let buttons: [SegmentedControl.Button] = [.init(name: Localizable.Receive.Button.cryptocurrency,
                                                        icon: .init(normal: Images.rGateway14Basic500.image,
                                                        selected: Images.rGateway14White.image)),
                                                  
                                                  .init(name: Localizable.Receive.Button.invoice,
                                                        icon: .init(normal: Images.rInwaves14Basic500.image,
                                                                    selected: Images.rInwaves14White.image)),
                                                  
                                                  .init(name: Localizable.Receive.Button.card,
                                                        icon: .init(normal: Images.rCard14Basic500.image,
                                                                    selected: Images.rCard14White.image))]
        
        
        segmentedControl.update(with: buttons)
        
    }
    
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
    }
}

//MARK: - Actions
private extension ReceiveContainerViewController {
    @IBAction func segmentedDidChange(_ sender: Any) {
        
        guard selectedIndex != segmentedControl.selectedIndex else { return }
        selectedIndex = segmentedControl.selectedIndex
        print(selectedIndex)
    }
}

//MARK: UIScrollViewDelegate
extension ReceiveContainerViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
}

//MARK: - Methods
extension ReceiveContainerViewController {
    
    func add(_ viewController: UIViewController) {
        viewControllers.append(viewController)
    }
}
