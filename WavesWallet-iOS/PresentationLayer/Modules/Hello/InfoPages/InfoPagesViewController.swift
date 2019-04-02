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

final class InfoPagesViewController: UIViewController {
    
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var toolbarLabel: UILabel!
    
    @IBOutlet weak var gradientView: CustomGradientView!
    
    @IBOutlet private weak var pageControl: UIPageControl!
    var collectionView: UICollectionView!

    @IBOutlet private weak var toolbarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var toolbarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nextControl: UIControl!

    // for fixing back when scrollingBackwards
    fileprivate(set) var prevOffsetX: CGFloat = 0
    
    private var isActiveConfirm: Bool = false
    
    weak var output: InfoPagesViewModuleOutput?
    
    private lazy var pageViews: [UIView] = {
        
        let welcomeView = ShortInfoPageView.loadView()
        let needToKnowView = ShortInfoPageView.loadView()
        let needToKnowLongView = LongInfoPageView.loadView()
        let protectView = ShortInfoPageView.loadView()
        let protectLongView = LongInfoPageView.loadView()
        let confirmView = InfoPageConfirmView.loadView()
        
        return [welcomeView, needToKnowView, needToKnowLongView, protectView, protectLongView, confirmView]
    }()
    
    private lazy var pageModels: [Any] = {
        
        let welcome = ShortInfoPageView.Model(title: Localizable.Waves.Hello.Page.Info.First.title,
                                              detail: Localizable.Waves.Hello.Page.Info.First.detail,
                                              firstImage: nil, secondImage: nil,
                                              thirdImage: nil,
                                              fourthImage: nil)
        
        let needToKnow = ShortInfoPageView.Model(title: Localizable.Waves.Hello.Page.Info.Second.title,
                                                 detail: Localizable.Waves.Hello.Page.Info.Second.detail,
                                                 firstImage: Images.iAnonim42Submit400.image,
                                                 secondImage: Images.iPassbrowser42Submit400.image,
                                                 thirdImage: Images.iBackup42Submit400.image,
                                                 fourthImage: Images.iShredder42Submit400.image)
        
        let needToKnowLong = LongInfoPageView.Model(title: Localizable.Waves.Hello.Page.Info.Third.title,
                                                    firstDetail: Localizable.Waves.Hello.Page.Info.Third.Detail.first,
                                                    secondDetail: Localizable.Waves.Hello.Page.Info.Third.Detail.second,
                                                    thirdDetail: Localizable.Waves.Hello.Page.Info.Third.Detail.third,
                                                    fourthDetail: Localizable.Waves.Hello.Page.Info.Third.Detail.fourth,
                                                    firstImage: Images.iAnonim42Submit400.image,
                                                    secondImage: Images.iPassbrowser42Submit400.image,
                                                    thirdImage: Images.iBackup42Submit400.image,
                                                    fourthImage: Images.iShredder42Submit400.image)
        
        let protect = ShortInfoPageView.Model(title: Localizable.Waves.Hello.Page.Info.Fourth.title,
                                              detail: Localizable.Waves.Hello.Page.Info.Fourth.detail,
                                              firstImage: Images.iMailopen42Submit400.image,
                                              secondImage: Images.iRefreshbrowser42Submit400.image,
                                              thirdImage: Images.iOs42Submit400.image,
                                              fourthImage: Images.iWifi42Submit400.image)
        
        let protectLong = LongInfoPageView.Model(title: Localizable.Waves.Hello.Page.Info.Fifth.title,
                                                 firstDetail: Localizable.Waves.Hello.Page.Info.Fifth.Detail.first,
                                                 secondDetail: Localizable.Waves.Hello.Page.Info.Fifth.Detail.second,
                                                 thirdDetail: Localizable.Waves.Hello.Page.Info.Fifth.Detail.third,
                                                 fourthDetail: Localizable.Waves.Hello.Page.Info.Fifth.Detail.fourth,
                                                 firstImage: Images.iMailopen42Submit400.image,
                                                 secondImage: Images.iRefreshbrowser42Submit400.image,
                                                 thirdImage: Images.iOs42Submit400.image,
                                                 fourthImage: Images.iWifi42Submit400.image)
        
        return [welcome, needToKnow, needToKnowLong, protect, protectLong]
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .basic50

        self.nextControl.accessibilityIdentifier = AccessibilityIdentifiers.Viewcontroller.Infopagesviewcontroller.Button.next

        navigationItem.isNavigationBarHidden = true

        setupCollectionView()
        setupPageControl()
        setupButtonTitle()
        setupConstraints()
        
        gradientView.endColor = .basic50
        toolbarView.addTableCellShadowStyle()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changedPage()
    }
    
    // MARK: - Setup

    private func setupPageControl() {
        pageControl.numberOfPages = pageViews.count
        pageControl.pageIndicatorTintColor = .basic200
        pageControl.currentPageIndicatorTintColor = .black
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        view.sendSubviewToBack(collectionView)
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds
        
    }

    private func setupConstraints() {
        if Platform.isIphone5 {
            toolbarBottomConstraint.constant = InfoPagesViewControllerConstants.ToolbarBottomOffset.small.rawValue
            toolbarLeadingConstraint.constant = InfoPagesViewControllerConstants.ToolbarLeadingOffset.small.rawValue
            toolbarTrailingConstraint.constant = InfoPagesViewControllerConstants.ToolbarTrailingOffset.small.rawValue
        }
        else {
            toolbarBottomConstraint.constant = InfoPagesViewControllerConstants.ToolbarBottomOffset.big.rawValue
            toolbarLeadingConstraint.constant = InfoPagesViewControllerConstants.ToolbarLeadingOffset.big.rawValue
            toolbarTrailingConstraint.constant = InfoPagesViewControllerConstants.ToolbarTrailingOffset.big.rawValue
        }
    }
    
    private func setupButtonTitle() {
        let currentPage = pageControl.currentPage
        
        if currentPage == pageViews.count - 1 {
            toolbarLabel.text = Constants.buttonBegin
        } else {
            toolbarLabel.text = Constants.buttonNext
        }
    }
    
    fileprivate func nextPage() {
        let page = pageControl.currentPage + 1
        
        if page < pageViews.count {
            collectionView.scrollToItem(at: IndexPath(item: page, section: 0), at: .left, animated: true)
        } else {
            output?.userFinishedReadPages()
            AnalyticManager.trackEvent(.newUser(.confirm))
        }
        
    }
    
    fileprivate func changedPage() {
        setupButtonTitle()
        
        let currentPage = pageControl.currentPage
        if currentPage < pageModels.count {
            if let currentModel = pageModels[currentPage] as? LongInfoPageView.Model {
                nextControl.isEnabled = currentModel.scrolledToBottom
                toolbarLabel.alpha = currentModel.scrolledToBottom ? 1 : 0.5
            } else if let currentModel = pageModels[currentPage] as? ShortInfoPageView.Model {
                nextControl.isEnabled = currentModel.scrolledToBottom
                toolbarLabel.alpha = currentModel.scrolledToBottom ? 1 : 0.5
            }
        }
        else {
            nextControl.isEnabled = isActiveConfirm
            toolbarLabel.alpha = isActiveConfirm ? 1 : 0.5
        }
    }
    
}

// MARK: - Actions

extension InfoPagesViewController {
    
    @IBAction func nextPageTap(_ sender: Any) {
        nextPage()
    }
}

// MARK: - Collection

extension InfoPagesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageViews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: InfoPagesCell = collectionView.dequeueAndRegisterCell(indexPath: indexPath)
        
        let pageView = pageViews[indexPath.item]
        
        if let pageView = pageView as? ShortInfoPageView {
            let pageModel = pageModels[indexPath.item]
            
            pageView.delegate = self
            pageView.update(with: pageModel as! ShortInfoPageView.Model)
            
        } else if let pageView = pageView as? LongInfoPageView {
            let pageModel = pageModels[indexPath.item]

            pageView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.bounds.height - toolbarView.frame.minY, right: 0)
            pageView.delegate = self
            pageView.update(with: pageModel as! LongInfoPageView.Model)
        }
        else if let pageView = pageView as? InfoPageConfirmView {
            pageView.delegate = self
        }
        
        pageView.backgroundColor = .basic50
        cell.update(with: pageView)
        
        return cell
    }
}

extension InfoPagesViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let pageView = pageViews[indexPath.item]
        
        if let pageView = pageView as? LongInfoPageView {
            pageView.updateOnScroll()
        }
        
        if let pageView = pageView as? ShortInfoPageView {
            pageView.updateOnScroll()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
}

extension InfoPagesViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == collectionView {
        
            let offsetX = scrollView.contentOffset.x
            let size = scrollView.bounds.width
            
            if size == 0 { return }
            
            var page = Int((offsetX + size / 2) / size)
            let maxOffset = size * CGFloat(page)

            if offsetX > maxOffset && !nextControl.isEnabled && offsetX > prevOffsetX {
                scrollView.contentOffset.x = maxOffset
            }
            
            page = max(min(pageViews.count - 1, page), 0)
            pageControl.currentPage = page
            
            changedPage()
            prevOffsetX = scrollView.contentOffset.x
 
        } 
    }
}

extension InfoPagesViewController: InfoPageConfirmViewDelegate {
    
    func infoPageConfirmView(isActive: Bool) {
        isActiveConfirm = isActive
        changedPage()
    }
    
    func infoPageContirmViewDidTapURL(_ url: URL) {
        let vc = BrowserViewController(url: url)
        
        let nav = CustomNavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
}

extension InfoPagesViewController: LongInfoPageViewDelegate {
    
    func longInfoPageViewDidScrollToBottom(view: LongInfoPageView) {
        
        guard let index = pageViews.firstIndex(where: { (pageView) -> Bool in
            return pageView == view
        }) else { return }
        
        if let model = pageModels[index] as? LongInfoPageView.Model {
             model.scrolledToBottom = true
        }
        
        changedPage()
    }
    
}

extension InfoPagesViewController: ShortInfoPageViewDelegate {
    
    func shortInfoPageViewDidScrollToBottom(view: ShortInfoPageView) {
        
        guard let index = pageViews.firstIndex(where: { (pageView) -> Bool in
            return pageView == view
        }) else { return }
        
        if let model = pageModels[index] as? ShortInfoPageView.Model {
            model.scrolledToBottom = true
        }
        
        changedPage()
    }
    
}

enum InfoPagesViewControllerConstants {
    
    enum ToolbarLeadingOffset: CGFloat {
        case small = 8
        case big = 14
    }
    
    enum ToolbarTrailingOffset: CGFloat {
        case small = 8
        case big = 14
    }
    
    enum ToolbarBottomOffset: CGFloat {
        case small = 14
        case big = 24
    }
    
    static let titleAttributes: [NSAttributedString.Key: Any] = {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: .bold), NSAttributedString.Key.kern: 0.4,
                          NSAttributedString.Key.foregroundColor: UIColor.black,
                          NSAttributedString.Key.paragraphStyle: style] as [NSAttributedString.Key : Any]
        
        return attributes
        
    }()
    
    static let subtitleAttributes: [NSAttributedString.Key: Any] = {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .semibold), NSAttributedString.Key.kern: 0.4,
                          NSAttributedString.Key.foregroundColor: UIColor.black,
                          NSAttributedString.Key.paragraphStyle: style] as [NSAttributedString.Key : Any]
        
        return attributes
        
    }()
    
    
    static let textAttributes: [NSAttributedString.Key: Any] = {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13), NSAttributedString.Key.kern: -0.1,
                          NSAttributedString.Key.foregroundColor: UIColor.black,
                          NSAttributedString.Key.paragraphStyle: style] as [NSAttributedString.Key : Any]
        
        return attributes
        
    }()
    
}

private enum Constants {
    static let buttonNext = Localizable.Waves.Hello.Button.next
    static let buttonBegin = Localizable.Waves.Hello.Button.begin
}
