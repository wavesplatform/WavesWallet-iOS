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
    @IBOutlet private weak var accentCircleHeight: NSLayoutConstraint!

    @IBOutlet private weak var pageControl: PageControl!
    @IBOutlet private weak var nextLabel: UILabel!
    @IBOutlet private weak var nextControl: UIControl!

    private var hasBegin = false {
        didSet {
            print(hasBegin)
        }
    }
    private var lastScreenIndex = 0

    private var presenterOutput: WelcomeScreenPresenterOutput?

    private let didTapBegin = PublishRelay<Void>()
    private let didTapUrl = PublishRelay<URL>()
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

        accentCircle.isHidden = true
        accentCircle.backgroundColor = UIColor.azureTwo.withAlphaComponent(0.2)

        nextLabel.text = Localizable.Waves.Hello.Button.next

        nextControl.addTarget(self,
                              action: #selector(didTapNextControl),
                              for: .touchUpInside)
    }

    @objc private func didTapNextControl() {
        let finalContentOffset = scrollView.contentOffset.x + scrollView.bounds.width
        
        if (pageControl.numberOfPages - 1) == lastScreenIndex, hasBegin {
            didTapBegin.accept(Void())
        }
        
        if finalContentOffset < scrollView.contentSize.width {
            scrollView.contentOffset.x = finalContentOffset
        }
    }
}

// MARK: - BindableView

extension WelcomeScreenViewController: BindableView {
    func getOutput() -> WelcomeScreenViewOutput {
        let viewWillAppear = ControlEvent(events: rx.viewWillAppear.mapAsVoid())

        return WelcomeScreenViewOutput(viewWillAppear: viewWillAppear,
                                       didTapBegin: didTapBegin.asControlEvent(),
                                       didTapUrl: didTapUrl.asControlEvent())
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

        let didTapUrl: (URL) -> Void = { [weak self] in self?.didTapUrl.accept($0) }
        let didHasReadPolicyAndTerms: (Bool) -> Void = { [weak self] in
            self?.hasBegin = $0
            self?.nextControl.isUserInteractionEnabled = $0
        }

        let views = viewModel.map {
            Helper.makeInfoView(with: $0, didTapUrl: didTapUrl, didHasReadPolicyAndTerms: didHasReadPolicyAndTerms)
        }
        stackView.addArrangedSubviews(views)

        pageControl.numberOfPages = views.count

        for view in views {
            view.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        }

        accentCircle.isHidden = false
        accentCircle.cornerRadius = Float(accentCircleHeight.constant / 2)
    }
}

// MARK: - Helper

extension WelcomeScreenViewController {
    private enum Helper {
        static func makeInfoView(with viewModel: WelcomeScreenViewModel,
                                 didTapUrl: @escaping (URL) -> Void,
                                 didHasReadPolicyAndTerms: @escaping (Bool) -> Void) -> UIView {
            if viewModel == .termOfConditions {
                return makeTermOfConditionsView(viewModel: viewModel,
                                                didTapUrl: didTapUrl,
                                                didHasReadPolicyAndTerms: didHasReadPolicyAndTerms)
            } else {
                return makeInfoView(titleText: viewModel.title,
                                    detailsText: viewModel.details,
                                    image: makeWelcomeScreenVMImage(viewModel))
            }
        }

        private static func makeTermOfConditionsView(viewModel: WelcomeScreenViewModel,
                                                     didTapUrl: @escaping (URL) -> Void,
                                                     didHasReadPolicyAndTerms: @escaping (Bool) -> Void) -> UIView {
            let privacyPolicyText = makeTermsAttributedString(title: viewModel.privacyPolicyText.title,
                                                              linkWord: viewModel.privacyPolicyText.model,
                                                              url: viewModel.privacyPolicyTextLink)

            let termOfConditionsText = makeTermsAttributedString(title: viewModel.termOfConditionsText.title,
                                                                 linkWord: viewModel.termOfConditionsText.model,
                                                                 url: viewModel.termOfConditionsTextLink)

            let view = WelcomeScreenTermOfConditionsView.loadFromNib()
            view.setTitleText(viewModel.title, detailsText: viewModel.details, image: makeWelcomeScreenVMImage(viewModel))
            view.setPrivacyPolicyText(privacyPolicyText,
                                      termOfConditionText: termOfConditionsText,
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

        private static func makeTermsAttributedString(title: String, linkWord: String, url: URL?) -> NSAttributedString {
            let mutableAttributeString = NSMutableAttributedString(string: title,
                                                                   attributes: [.font: UIFont.bodyRegular,
                                                                                .foregroundColor: UIColor.black])
            if let url = url {
                mutableAttributeString.addAttribute(.link,
                                                    value: url,
                                                    range: mutableAttributeString.mutableString.range(of: linkWord))
            }

            mutableAttributeString.addAttribute(.foregroundColor,
                                                value: UIColor.submit400,
                                                range: mutableAttributeString.mutableString.range(of: linkWord))
            return mutableAttributeString
        }

        private static func makeWelcomeScreenVMImage(_ viewModel: WelcomeScreenViewModel) -> UIImage {
            switch viewModel {
            case .hello: return Images.Illustrations.candleChart.image
            case .easyRefill: return Images.Illustrations.terminal.image
            case .invesmentInfo: return Images.Illustrations.investments.image
            case .termOfConditions: return Images.Illustrations.safeInvestment.image
            }
        }
    }
}

extension WelcomeScreenViewController: UIScrollViewDelegate {
    private enum Constants {
        static let scaleStep: CGFloat = 55
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

        defer {
            lastScreenIndex = indexScreen
            pageControl.currentPage = indexScreen

            let isLastPage = lastScreenIndex == (pageControl.numberOfPages - 1)
            let labelText = isLastPage ? Localizable.Waves.Hello.Button.begin : Localizable.Waves.Hello.Button.next
            nextLabel.text = labelText
        }

        let screenWidth = scrollView.bounds.width

        let contentOffsetX = max(0, scrollView.contentOffset.x)

        let indexScreen = Int(contentOffsetX / screenWidth)

        UIView.animate(withDuration: 0.5) {
            if indexScreen > self.lastScreenIndex {
                self.accentCircleHeight.constant += Constants.scaleStep * CGFloat(indexScreen + 1)
                self.accentCircle.cornerRadius = Float(self.accentCircleHeight.constant / 2)
            } else if indexScreen < self.lastScreenIndex {
                self.accentCircleHeight.constant -= Constants.scaleStep * CGFloat(self.lastScreenIndex + 1)
                self.accentCircle.cornerRadius = Float(self.accentCircleHeight.constant / 2)
            } else {
                return
            }

            self.accentCircle.layoutIfNeeded()
        }
    }

    func scrollViewDidEndDecelerating(_: UIScrollView) {
//        let finalContentOffsetX = CGFloat(indexScreen) * screenWidth
//
//        let fraction = contentOffsetX / finalContentOffsetX

//        defer {
//            lastScreenIndex = indexScreen
//            pageControl.currentPage = indexScreen - 1
//        }
//
//        let screenWidth = scrollView.bounds.width
//
//        let contentOffsetX = max(0, scrollView.contentOffset.x)
//
//        let indexScreen = Int(contentOffsetX / screenWidth) + 1
//
//        UIView.animate(withDuration: 0.5) {
//            if indexScreen > self.lastScreenIndex {
//                self.accentCircleHeight.constant += Constants.scaleStep * CGFloat(indexScreen)
//                self.accentCircle.cornerRadius = Float(self.accentCircleHeight.constant / 2)
//            } else if indexScreen < self.lastScreenIndex {
//                self.accentCircleHeight.constant -= Constants.scaleStep * CGFloat(self.lastScreenIndex)
//                self.accentCircle.cornerRadius = Float(self.accentCircleHeight.constant / 2)
//            } else {
//                return
//            }
//
//            self.accentCircle.layoutIfNeeded()
//        }
    }
}

// MARK: - StoryboardInstantiatable

extension WelcomeScreenViewController: StoryboardInstantiatable {}
