//
//  ReceiveContainerViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/2/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum SelectedState: Int {
    case cryptoCurrency
    case invoive
    case card
}

final class ReceiveContainerViewController: UIViewController {

    private var viewControllers: [UIViewController] = []
    
    @IBOutlet private weak var segmentedControl: SegmentedControl!
    
    private var selectedState = SelectedState.cryptoCurrency
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Localizable.Receive.Label.receive
        createBackButton()
        setupSegmentedControl()
        
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBigNavigationBar()
    }
}

//MARK: - Actions
private extension ReceiveContainerViewController {
    
    @IBAction func segmentedDidChange(_ sender: Any) {
        
//        selectedIndex = segmentedControl.selectedIndex
//        print(selectedIndex)
    }
    
    @objc func handleGesture(_ gesture: UISwipeGestureRecognizer) {
        
//        if gesture.direction == .left {
//
//            let index = segmentedControl.selectedIndex + 1
//            if index <= SelectedState.card.rawValue {
//                segmentedControl.selectedIndex = index
//                selectedSegmentIndex = ReceiveState(rawValue: index)!
//                setupButtons(selectedButton: activeButton, animation: true)
//            }
//        }
//        else if gesture.direction == .right {
//
//            let index = selectedSegmentIndex.rawValue - 1
//            if index >= 0 {
//                selectedSegmentIndex = ReceiveState(rawValue: index)!
//                setupButtons(selectedButton: activeButton, animation: true)
//            }
//        }
    }
}

//MARK: - SetupUI
private extension ReceiveContainerViewController {

    func setupSwipeGestures() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        scrollViewContainer.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        swipeLeft.direction = .left
        scrollViewContainer.addGestureRecognizer(swipeLeft)
    }
    
    func setupSegmentedControl() {
        
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
