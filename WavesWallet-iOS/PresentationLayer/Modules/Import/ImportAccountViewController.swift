//
//  ImportAccountViewController.swift
//  WavesWallet-iOS
//
//  Created by Mac on 08/11/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import RxCocoa
import RxFeedback
import RxSwift

class ImportAccountViewController: UIViewController {
    
    struct Section {
        let id: Int
        let title: String
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    lazy var scanViewController: ImportAccountScanViewController = {
        return StoryboardScene.Import.importAccountScanViewController.instantiate()
    }()
    
    lazy var manuallyViewController: ImportAccountManuallyViewController = {
        return StoryboardScene.Import.importAccountManuallyViewController.instantiate()
    }()
    
    @IBOutlet weak var segmentedControl: WalletSegmentedControl!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        navigationItem.title = Localizable.Waves.Import.General.Navigation.title
        view.backgroundColor = .basic50
        
        setupBigNavigationBar()
        createBackButton()
        hideTopBarLine()

        setupViewControllers()
        setupSegmentedControl()
        
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        currentIndex = 0
    }
    
    private func setupSegmentedControl() {
        let buttons = sections.map { SegmentedControl.Button(name: $0.title) }
        
        segmentedControl
            .segmentedControl
            .update(with: buttons, animated: true)
        
         segmentedControl.segmentedControl.scrollView.changedValue = { newValue in
                self.currentIndex = newValue
        }
    }
    
    private func setupViewControllers() {
        addChildViewController(scanViewController)
        scanViewController.view.frame = containerView.bounds
        containerView.addSubview(scanViewController.view)
        
        scanViewController.didMove(toParentViewController: self)

        addChildViewController(manuallyViewController)
        manuallyViewController.view.frame = containerView.bounds
        containerView.addSubview(manuallyViewController.view)
        
        manuallyViewController.didMove(toParentViewController: self)

        scanViewController.view.isHidden = true
        manuallyViewController.view.isHidden = true        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scanViewController.view.frame = containerView.bounds
        manuallyViewController.view.frame = containerView.bounds
    }
    
    // MARK: - Content
    
    private var sections: [Section] {
        return [
            Section(id: 0, title: Localizable.Waves.Import.General.Segmentedcontrol.scan),
            Section(id: 1, title: Localizable.Waves.Import.General.Segmentedcontrol.manually)
        ]
    }
    
    private var currentIndex: Int = 0 {
        didSet {
            for vc in viewControllers {
                vc.view.isHidden = true
            }
            
            currentViewController?.view.isHidden = false
            
            guard let currentViewController = currentViewController else { return }
            
            if currentViewController == scanViewController {
                manuallyViewController.resignKeyboard(animated: true)
            } else if currentViewController == manuallyViewController {
                manuallyViewController.showKeyboard(animated: true)
            }
        }
    }
    
    private var currentViewController: UIViewController? {
        return viewControllers[currentIndex]
    }
    
    private var viewControllers: [UIViewController] {
        return [scanViewController, manuallyViewController]
    }
    
}

extension ImportAccountViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
    
}
