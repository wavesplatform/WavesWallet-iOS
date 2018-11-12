//
//  DexTraderContainerViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol DexTraderContainerProcotol {
    func controllerWillAppear()
    func controllerWillDissapear()
}

final class DexTraderContainerViewController: UIViewController {

    @IBOutlet weak var segmentedControl: DexTraderContainerSegmentedControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var pair: DexTraderContainer.DTO.Pair!
    weak var moduleOutput: DexTraderContainerModuleOutput?
    
    private var viewControllers: [UIViewController] = []
    private var scrolledPages: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.delegate = self
        title = pair.amountAsset.shortName + " / " + pair.priceAsset.shortName
        createBackWhiteButton()
        addInfoButton()
        buildControllers()
        setupScrollEnabled(currentPage: scrollView.currentPage)
        updateControllersActiveState(page: scrollView.currentPage)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSmallNavigationBar()
        hideTopBarLine()
        navigationItem.backgroundImage = UIImage()
        navigationItem.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        for view in scrollView.subviews {
            setupViewControllerSize(view: view)
        }
    }
    
    var controllers: [UIViewController] {
        return viewControllers
    }
    
    private func updateControllersActiveState(page: Int) {
        for (index, controller) in viewControllers.enumerated() {
            if let vc = controller as? DexTraderContainerProcotol {
                if index == page {
                    vc.controllerWillAppear()
                }
                else {
                    vc.controllerWillDissapear()
                }
            }
        }
    }
}

extension DexTraderContainerViewController: DexTraderContainerInputProtocol {
    func addViewController(_ viewController: UIViewController, isScrollEnabled: Bool) {
        viewControllers.append(viewController)
        if let index = viewControllers.index(of: viewController), isScrollEnabled {
            scrolledPages.append(index)
        }
    }
}

//MARK: - Actions
private extension DexTraderContainerViewController {
    
    @objc func infoTapped() {
        let infoPair = DexInfoPair.DTO.Pair(amountAsset: pair.amountAsset, priceAsset: pair.priceAsset, isGeneral: pair.isGeneral)
        moduleOutput?.showInfo(pair: infoPair)
    }
    
}

//MARK: - DexTranderContainerSegmentedControlDelegate
extension DexTraderContainerViewController: DexTraderContainerSegmentedControlDelegate {
    
    func segmentedControlDidChangeState(_ state: DexTraderContainerSegmentedControl.SegmentedState) {
        scrollToPageIndex(state.rawValue)
        setupScrollEnabled(currentPage: state.rawValue)
        updateControllersActiveState(page: state.rawValue)
    }
}

//MARK: - UIScrollViewDelegate
extension DexTraderContainerViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if segmentedControl.selectedState.rawValue != scrollView.currentPage {
            updateControllersActiveState(page: scrollView.currentPage)
        }
        
        segmentedControl.changeStateToScrollPage(scrollView.currentPage)
        setupScrollEnabled(currentPage: scrollView.currentPage)
    }
}


//MARK: - Setup UI
private extension DexTraderContainerViewController {
    
    func setupScrollEnabled(currentPage: Int) {
        scrollView.isScrollEnabled = scrolledPages.contains(currentPage)
    }
    
    func scrollToPageIndex(_ pageIndex: Int) {
        scrollView.setContentOffset(CGPoint(x: CGFloat(pageIndex) * scrollView.frame.size.width,
                                            y: scrollView.contentOffset.y), animated: true)
    }
    
    func addInfoButton() {
        let btn = UIBarButtonItem(image: Images.topbarInfowhite.image, style: .plain, target: self, action: #selector(infoTapped))
        btn.tintColor = .white
        navigationItem.rightBarButtonItem = btn
    }
    
    func buildControllers() {
        for (index, controller) in viewControllers.enumerated() {
            addController(controller, atIndex: index)
        }
        scrollView.contentSize = CGSize(width: CGFloat(viewControllers.count) * Platform.ScreenWidth, height: scrollView.contentSize.height)
    }
    
    func addController(_ viewController: UIViewController, atIndex: Int) {
        scrollView.addSubview(viewController.view)
        setupViewControllerSize(view: viewController.view)
        viewController.view.frame.origin.x = CGFloat(atIndex) * Platform.ScreenWidth
        addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
    }
    
    func setupViewControllerSize(view: UIView) {
        view.frame.size = scrollView.bounds.size
    }
}
