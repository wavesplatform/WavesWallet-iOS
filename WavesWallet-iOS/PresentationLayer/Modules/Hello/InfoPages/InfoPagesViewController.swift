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
    
    weak var output: InfoPagesViewModuleOutput?
    
    private lazy var pageViews: [UIView] = {
        
        let welcomeView = ShortInfoPageView.loadView() as! ShortInfoPageView
        let needToKnowView = ShortInfoPageView.loadView() as! ShortInfoPageView
        let needToKnowLongView = LongInfoPageView.loadView() as! LongInfoPageView
        let protectView = ShortInfoPageView.loadView() as! ShortInfoPageView
        let protectLongView = LongInfoPageView.loadView() as! LongInfoPageView

        return [welcomeView, needToKnowView, needToKnowLongView, protectView, protectLongView]
    }()
    
    private lazy var pageModels: [Any] = {
        
        let welcome = ShortInfoPageView.Model(title: Localizable.Waves.Hello.Page.Info.First.title, detail: Localizable.Waves.Hello.Page.Info.First.detail, firstImage: nil, secondImage: nil, thirdImage: nil, fourthImage: nil)
        
        let needToKnow = ShortInfoPageView.Model(title: Localizable.Waves.Hello.Page.Info.Second.title, detail: Localizable.Waves.Hello.Page.Info.Second.detail, firstImage: Images.iAnonim42Submit400.image, secondImage: Images.iPassbrowser42Submit400.image, thirdImage: Images.iBackup42Submit400.image, fourthImage: Images.iShredder42Submit400.image)
        
        let needToKnowLong = LongInfoPageView.Model(title: Localizable.Waves.Hello.Page.Info.Third.title, firstDetail: Localizable.Waves.Hello.Page.Info.Third.Detail.first, secondDetail: Localizable.Waves.Hello.Page.Info.Third.Detail.second, thirdDetail: Localizable.Waves.Hello.Page.Info.Third.Detail.third, fourthDetail: Localizable.Waves.Hello.Page.Info.Third.Detail.fourth, firstImage: Images.iAnonim42Submit400.image, secondImage: Images.iPassbrowser42Submit400.image, thirdImage: Images.iBackup42Submit400.image, fourthImage: Images.iShredder42Submit400.image)
        
        let protect = ShortInfoPageView.Model(title: Localizable.Waves.Hello.Page.Info.Fourth.title, detail: Localizable.Waves.Hello.Page.Info.Fourth.detail, firstImage: Images.iMailopen42Submit400.image, secondImage: Images.iRefreshbrowser42Submit400.image, thirdImage: Images.iOs42Submit400.image, fourthImage: Images.iWifi42Submit400.image)
        
        let protectLong = LongInfoPageView.Model(title: Localizable.Waves.Hello.Page.Info.Fifth.title, firstDetail: Localizable.Waves.Hello.Page.Info.Fifth.Detail.first, secondDetail: Localizable.Waves.Hello.Page.Info.Fifth.Detail.second, thirdDetail: Localizable.Waves.Hello.Page.Info.Fifth.Detail.third, fourthDetail: Localizable.Waves.Hello.Page.Info.Fifth.Detail.fourth, firstImage: Images.iMailopen42Submit400.image, secondImage: Images.iRefreshbrowser42Submit400.image, thirdImage: Images.iOs42Submit400.image, fourthImage: Images.iWifi42Submit400.image)
        
        return [welcome, needToKnow, needToKnowLong, protect, protectLong]
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .basic50
        navigationController?.setNavigationBarHidden(true, animated: false)

        setupCollectionView()
        setupPageControl()
        setupButtonTitle()
        setupConstraints()
        
        gradientView.endColor = .basic50
        toolbarView.addTableCellShadowStyle()
        
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
        view.sendSubview(toBack: collectionView)
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
        } else if Platform.isIphoneX || Platform.isIphonePlus {
            toolbarBottomConstraint.constant = InfoPagesViewControllerConstants.ToolbarBottomOffset.big.rawValue
            toolbarLeadingConstraint.constant = InfoPagesViewControllerConstants.ToolbarLeadingOffset.big.rawValue
            toolbarTrailingConstraint.constant = InfoPagesViewControllerConstants.ToolbarTrailingOffset.big.rawValue
        } else {
            toolbarBottomConstraint.constant = InfoPagesViewControllerConstants.ToolbarBottomOffset.big.rawValue
            toolbarLeadingConstraint.constant = InfoPagesViewControllerConstants.ToolbarLeadingOffset.big.rawValue
            toolbarTrailingConstraint.constant = InfoPagesViewControllerConstants.ToolbarTrailingOffset.big.rawValue
        }
    }
    
    private func setupButtonTitle() {
        let currentPage = pageControl.currentPage
        
        if currentPage == pageViews.count - 1 {
            toolbarLabel.text = Constants.buttonUnderstand
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
        }
        
    }
    
    fileprivate func changedPage() {
        setupButtonTitle()
        
        let currentPage = pageControl.currentPage
        
        if let currentModel = pageModels[currentPage] as? LongInfoPageView.Model {
            nextControl.isEnabled = currentModel.scrolledToBottom
            toolbarLabel.alpha = currentModel.scrolledToBottom ? 1 : 0.5
        } else {
            nextControl.isEnabled = true
            toolbarLabel.alpha = 1
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
        let pageModel = pageModels[indexPath.item]
        
        if let pageView = pageView as? ShortInfoPageView {
            
            pageView.update(with: pageModel as! ShortInfoPageView.Model)
            
        } else if let pageView = pageView as? LongInfoPageView {
            
            pageView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.bounds.height - toolbarView.frame.minY, right: 0)
            pageView.delegate = self
            pageView.update(with: pageModel as! LongInfoPageView.Model)
            
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
//            print(offsetX, maxOffset)
            if offsetX > maxOffset && !nextControl.isEnabled && offsetX > prevOffsetX {
                print(offsetX, maxOffset)
                scrollView.contentOffset.x = maxOffset
            }
            
            page = max(min(pageViews.count - 1, page), 0)
            pageControl.currentPage = page
            
            changedPage()
            prevOffsetX = scrollView.contentOffset.x
 
        } 
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        scrollToRight = scro
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
    
    static let titleAttributes: [NSAttributedStringKey: Any] = {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0
        
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 34, weight: .bold), NSAttributedStringKey.kern: 0.4,
                          NSAttributedStringKey.foregroundColor: UIColor.black,
                          NSAttributedStringKey.paragraphStyle: style] as [NSAttributedStringKey : Any]
        
        return attributes
        
    }()
    
    static let subtitleAttributes: [NSAttributedStringKey: Any] = {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 0
        
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13, weight: .semibold), NSAttributedStringKey.kern: 0.4,
                          NSAttributedStringKey.foregroundColor: UIColor.black,
                          NSAttributedStringKey.paragraphStyle: style] as [NSAttributedStringKey : Any]
        
        return attributes
        
    }()
    
    
    static let textAttributes: [NSAttributedStringKey: Any] = {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13), NSAttributedStringKey.kern: -0.1,
                          NSAttributedStringKey.foregroundColor: UIColor.black,
                          NSAttributedStringKey.paragraphStyle: style] as [NSAttributedStringKey : Any]
        
        return attributes
        
    }()
    
}

private enum Constants {
    static let buttonNext = Localizable.Waves.Hello.Button.next
    static let buttonUnderstand = Localizable.Waves.Hello.Button.understand
}
