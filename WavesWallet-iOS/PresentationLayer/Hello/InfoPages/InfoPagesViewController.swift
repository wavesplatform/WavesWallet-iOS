//
//  InfoPagesViewController.swift
//  WavesWallet-iOS
//
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import Koloda

protocol InfoPagesViewModuleOutput: AnyObject {
    func userFinishedReadPages()
}

final class InfoPagesViewController: UIViewController, KolodaViewDelegate, KolodaViewDataSource {
    
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var kolodaView: KolodaView!
    @IBOutlet private weak var kolodaTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var kolodaBotConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pageControlBotConstraint: NSLayoutConstraint!

    weak var output: InfoPagesViewModuleOutput?
    
    private var pageViews: [UIView] {
        
        let firstView = FirstInfoPageView.loadView() as! FirstInfoPageView
        let secondView = SecondInfoPageView.loadView() as! SecondInfoPageView
        let thirdView = ThirdIndoPageView.loadView() as! ThirdIndoPageView
        let fourthView = FourthInfoPageView.loadView() as! FourthInfoPageView
        let fifthView = FifthInfoPageView.loadView() as! FifthInfoPageView
        let sixthView = SixthInfoPageView.loadView() as! SixthInfoPageView
        let seventhView = SeventhInfoPageView.loadView() as! SeventhInfoPageView
        
        firstView.nextBtn.addTarget(self, action: #selector(changePage), for: .touchUpInside)
        secondView.nextBtn.addTarget(self, action: #selector(changePage), for: .touchUpInside)
        thirdView.nextBtn.addTarget(self, action: #selector(changePage), for: .touchUpInside)
        fourthView.nextBtn.addTarget(self, action: #selector(changePage), for: .touchUpInside)
        fifthView.nextBtn.addTarget(self, action: #selector(changePage), for: .touchUpInside)
        sixthView.nextBtn.addTarget(self, action: #selector(changePage), for: .touchUpInside)
        seventhView.nextBtn.addTarget(self, action: #selector(changePage), for: .touchUpInside)
        
        firstView.setupConstraints()
        secondView.setupConstraints()
        thirdView.setupConstraints()
        fourthView.setupConstraints()
        fifthView.setupConstraints()
        sixthView.setupConstraints()
        seventhView.setupConstraints()

        return [firstView, secondView, thirdView, fourthView, fifthView, sixthView, seventhView]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addBgBlueImage()
        setupConstraints()
        navigationController?.setNavigationBarHidden(true, animated: false)
        kolodaView.countOfVisibleCards = 4
        kolodaView.appearanceAnimationDuration = 0.3
        kolodaView.delegate = self
        kolodaView.dataSource = self
        pageControl.numberOfPages = kolodaView.countOfCards
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //TODO: Changes
    private func setupConstraints() {
        if Platform.isIphone5 {
            kolodaTopConstraint.constant = 44
            kolodaBotConstraint.constant = 34
            pageControlBotConstraint.constant = 14
        }
        else if Platform.isIphoneX || Platform.isIphonePlus {
            kolodaTopConstraint.constant = 84
            kolodaBotConstraint.constant = 54
            pageControlBotConstraint.constant = 24
        }
        else {
            kolodaTopConstraint.constant = 44
            kolodaBotConstraint.constant = 54
            pageControlBotConstraint.constant = 24
        }
    }
    
    @objc func changePage() {
        kolodaView.swipe(.left)
        pageControl.currentPage = kolodaView.currentCardIndex
    }

    //MARK: - KolodaViewDelegate, KolodaViewDataSource
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return pageViews[index]
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return pageViews.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        output?.userFinishedReadPages()
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(_ koloda: KolodaView, shouldDragCardAt index: Int) -> Bool {
        return false
    }
}
