//
//  WelcomeScreenViewController.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 19.06.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import AppTools
import RxCocoa
import RxSwift
import UIKit
import UITools

final class WelcomeScreenViewController: UIViewController, WelcomeScreenViewControllable {
    var interactor: WelcomeScreenInteractable?

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var stackView: UIStackView!

    private var presenterOutput: WelcomeScreenPresenterOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        bindIfNeeded()
    }
    
    private func initialSetup() {
        navigationItem.isNavigationBarHidden = true
        navigationItem.largeTitleDisplayMode = .never
        
        scrollView.isPagingEnabled = true
    }
}

// MARK: - BindableView

extension WelcomeScreenViewController: BindableView {
    func getOutput() -> WelcomeScreenViewOutput {
//        let viewWillAppear = ControlEvent(events: rx.viewWillAppear.mapAsVoid())
        
        return WelcomeScreenViewOutput(viewWillAppear: rx.viewWillAppear.mapAsVoid())
    }

    func bindWith(_ input: WelcomeScreenPresenterOutput) {
        presenterOutput = input
        bindIfNeeded()
    }
    
    private func makeInfoView(titleText: String, detailsText: String, image: UIImage) -> UIView {
        let infoView = WelcomeScreenInfoView.loadFromNib()
        infoView.setTitleText(titleText, detailsText: detailsText, image: image)
        infoView.translatesAutoresizingMaskIntoConstraints = false
        return infoView
    }

    private func bindIfNeeded() {
        guard let input = presenterOutput, isViewLoaded else { return }
        
        stackView.subviews.forEach { $0.removeFromSuperview() }
        let images: [UIImage] = [Images.Illustrations.candleChart.image,
                                 Images.Illustrations.investments.image,
                                 Images.Illustrations.safeInvestment.image,
                                 Images.Illustrations.terminal.image]
        for image in images {
            let view = makeInfoView(titleText: "456464564646456456456456",
                                    detailsText: "12312313123123123123123123123",
                                    image: image)
            stackView.addArrangedSubview(view)
            view.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        }
    }
}

// MARK: - StoryboardInstantiatable

extension WelcomeScreenViewController: StoryboardInstantiatable {}
