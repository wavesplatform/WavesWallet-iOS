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
    @IBOutlet private weak var accentCircle: UIView!
    @IBOutlet weak var accentCircleHeight: NSLayoutConstraint!
    
    private var lastScreenIndex = 0
    
    private var presenterOutput: WelcomeScreenPresenterOutput?

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        bindIfNeeded()
    }

    private func initialSetup() {
        navigationItem.isNavigationBarHidden = true
        navigationItem.largeTitleDisplayMode = .never

        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .clear
        scrollView.delegate = self
        
        accentCircle.backgroundColor = UIColor.azureTwo.withAlphaComponent(0.2)
        accentCircle.cornerRadius = 100
    }
}

// MARK: - BindableView

extension WelcomeScreenViewController: BindableView {
    func getOutput() -> WelcomeScreenViewOutput {
        let viewWillAppear = ControlEvent(events: rx.viewWillAppear.mapAsVoid())

        return WelcomeScreenViewOutput(viewWillAppear: viewWillAppear)
    }

    func bindWith(_ input: WelcomeScreenPresenterOutput) {
        presenterOutput = input
        bindIfNeeded()
    }

    private func bindIfNeeded() {
        guard let input = presenterOutput, isViewLoaded else { return }

        input.viewModel
            .drive(onNext: { [weak self] viewModel in self?.bindViewModel(viewModel: viewModel) })
            .disposed(by: disposeBag)
    }

    private func bindViewModel(viewModel: [WelcomeScreenViewModel]) {
        stackView.subviews.forEach { $0.removeFromSuperview() }

        let views = viewModel.map { Helper.makeInfoView(with: $0) }
        stackView.addArrangedSubviews(views)
        
        for view in views {
            view.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        }
    }
}

// MARK: - Helper

extension WelcomeScreenViewController {
    private enum Helper {
        static func makeInfoView(with viewModel: WelcomeScreenViewModel) -> UIView {
            let welcomeScreenVMAdapter: (WelcomeScreenViewModel) -> UIImage = { viewModel -> UIImage in
                switch viewModel {
                case .hello: return Images.Illustrations.candleChart.image
                case .easyRefill: return Images.Illustrations.terminal.image
                case .invesmentInfo: return Images.Illustrations.investments.image
                case .termOfConditions: return Images.Illustrations.safeInvestment.image
                }
            }
            
            if viewModel == .termOfConditions {
                return makeTermOfConditionsView(viewModel: viewModel,
                                                image: welcomeScreenVMAdapter(viewModel),
                                                didTapUrl: { _ in },
                                                didHasReadPolicyAndTerms: { _ in })
            } else {
                return makeInfoView(titleText: viewModel.title,
                                    detailsText: viewModel.details,
                                    image: welcomeScreenVMAdapter(viewModel))
            }
        }
        
        private static func makeTermOfConditionsView(viewModel: WelcomeScreenViewModel,
                                                     image: UIImage,
                                                     didTapUrl: @escaping (URL) -> Void,
                                                     didHasReadPolicyAndTerms: @escaping (Bool) -> Void) -> UIView {
            let termOfConditionsAttributeText = viewModel.termOfConditionsItems.map { titledModel -> NSAttributedString in
                let mutableAttributeString = NSMutableAttributedString(string: titledModel.title,
                                                                       attributes: [.font: UIFont.bodyRegular,
                                                                                    .foregroundColor: UIColor.black])
                mutableAttributeString.addAttribute(.link,
                                                    value: "https://google.com",
                                                    range: mutableAttributeString.mutableString.range(of: titledModel.model))
                mutableAttributeString.addAttribute(.foregroundColor,
                                                    value: UIColor.submit400,
                                                    range: mutableAttributeString.mutableString.range(of: titledModel.model))
                return mutableAttributeString
            }
            
            let view = WelcomeScreenTermOfConditionsView.loadFromNib()
            view.setTitleText(viewModel.title, detailsText: viewModel.details, image: image)
            view.setPrivacyPolicyText(termOfConditionsAttributeText.first!,
                                      termOfConditionText: termOfConditionsAttributeText.last!,
                                      didTapUrl: didTapUrl,
                                      didHasReadPolicyAndTerms: didHasReadPolicyAndTerms)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }

        private static func makeInfoView(titleText: String, detailsText: String, image: UIImage) -> UIView {
            let infoView = WelcomeScreenInfoView.loadFromNib()
            infoView.backgroundColor = .clear
            infoView.setTitleText(titleText, detailsText: detailsText, image: image)
            infoView.translatesAutoresizingMaskIntoConstraints = false
            return infoView
        }
    }
}

extension WelcomeScreenViewController: UIScrollViewDelegate {
    private enum Constants {
        static let scaleStep: CGFloat = 25
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let screenWidth = scrollView.bounds.width
//
//        let contentOffsetX = max(0, scrollView.contentOffset.x)
//
//        let indexScreen = Int(contentOffsetX / screenWidth) + 1
//
//        let finalContentOffsetX = CGFloat(indexScreen) * screenWidth
//
//        let fraction = contentOffsetX / finalContentOffsetX
//
//        print("index = \(indexScreen)")
//        print("current x content offset = \(contentOffsetX)")
//        print("final content offset x = \(finalContentOffsetX)")
//        print("fraction = \(fraction)")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        defer { lastScreenIndex = indexScreen }
        
        let screenWidth = scrollView.bounds.width
        
        let contentOffsetX = max(0, scrollView.contentOffset.x)
        
        let indexScreen = Int(contentOffsetX / screenWidth) + 1
        
        UIView.animate(withDuration: 0.5) {
            if indexScreen > self.lastScreenIndex {
                self.accentCircleHeight.constant += 30 * CGFloat(indexScreen)
                self.accentCircle.cornerRadius = Float(self.accentCircleHeight.constant / 2)
            } else if indexScreen < self.lastScreenIndex {
                self.accentCircleHeight.constant -= 30 * CGFloat(indexScreen)
                self.accentCircle.cornerRadius = Float(self.accentCircleHeight.constant / 2)
            } else {
                return
            }
            
            self.accentCircle.layoutIfNeeded()
        }
        
//        let finalContentOffsetX = CGFloat(indexScreen) * screenWidth
//
//        let fraction = contentOffsetX / finalContentOffsetX
    }
}

// MARK: - StoryboardInstantiatable

extension WelcomeScreenViewController: StoryboardInstantiatable {}
