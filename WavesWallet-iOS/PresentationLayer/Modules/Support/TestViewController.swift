//
//  TestViewController.swift
//  
//
//  Created by mefilt on 31/01/2019.
//

import Foundation
import UIKit


final class ModalScrollViewController: UIViewController {

    private var needUpdateInsets: Bool = true

    var scrollView: UIScrollView {
        return UIScrollView()
    }

    func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        return 0
    }
}


final class ModalTableView: UITableView {

    private(set) lazy var backgroundModalView = UIView()

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundModalView.frame = CGRect(x: 0,
                                  y: contentSize.height,
                                  width: bounds.width,
                                  height: contentSize.height)

        insertSubview(backgroundModalView, at: 0)
    }
}


final class TestView: UIView {

    @IBOutlet var tableView: ModalTableView!

    let view: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        setupHeaderView()
    }

    func setupHeaderView() {

//        tableView.addSubview(view)



        let view: UIView = {
            let view = UIView()
            view.backgroundColor = .clear
//            view.fra
            return view
        }()

        tableView.tableHeaderView?.frame = frame


        let image = UIImageView(image: UIImage(named: "dragElem"))
        image.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(image)

        NSLayoutConstraint.activate([view.topAnchor.constraint(equalTo: image.topAnchor, constant: -6),
                                     view.centerXAnchor.constraint(equalTo: image.centerXAnchor, constant: 0)])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let headerTopY = max(0, -self.tableView.contentOffset.y)
        var frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 24)
        frame.origin.y = headerTopY


    }
}

final class TestViewController: UIViewController {

    @IBOutlet var tableView: ModalTableView!

    private var needUpdateInsets: Bool = true

    private var languages: [Language] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        var newList = Language.list
        newList.append(contentsOf: Language.list)

        let number = Int.random(in: 0..<newList.count)
        self.languages = Array(newList.prefix(max(number, 2)))
        self.tableView.reloadData()

        tableView.backgroundModalView.backgroundColor = .white

        self.tableView.shouldPassthroughTouch = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if needUpdateInsets {
            setupInsets()
        }
    }
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupScrollView()
        needUpdateInsets = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.tableView.contentInset.top = -self.tableView.contentOffset.y
        self.tableView.contentOffset.y = -self.tableView.contentInset.top
        self.tableView.showsVerticalScrollIndicator = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else {
            return
        }
    }

    private func setupInsets() {
        let top = view.frame.height - visibleScrollViewHeight(for: view.frame.size)
        self.tableView.contentInset.top = top
        self.tableView.scrollIndicatorInsets.top = top
        self.tableView.contentOffset.y = -top
    }
    

    private func setupScrollView() {

        var currentView: UIView? = tableView

        repeat {
            currentView?.shouldPassthroughTouch = true
            currentView = currentView?.superview
        } while currentView != view.superview

    }
}

extension TestViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Content") else { return UITableViewCell() }
        let language = languages[indexPath.row]

        let iconImageView = cell.viewWithTag(100) as? UIImageView
        let nameLabelView = cell.viewWithTag(200) as? UILabel

        iconImageView?.image = UIImage(named: language.icon)
        nameLabelView?.text = language.title

        return cell
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}


extension TestViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let dismissBlock = {
            targetContentOffset.pointee = scrollView.contentOffset
            self.dismiss(animated: true)
        }

        let verticalVelocity = abs(min(0, velocity.y))

        let distanceForDismiss = visibleScrollViewHeight(for: scrollView.bounds.size) - 50
        let distanceFromBottomEdge = scrollView.bounds.height + scrollView.contentOffset.y

        if verticalVelocity > 1 && distanceFromBottomEdge < distanceForDismiss {
            dismissBlock()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.setNeedsLayout()
    }
}

extension TestViewController: PopoverPresentationAnimatorContext {

    func appearingContectHeight(for size:  CGSize) -> CGFloat {

        let scrollViewHeight = self.visibleScrollViewHeight(for: size)

        return 0
    }

    func disappearingContectHeight(for size:  CGSize) -> CGFloat {

        let scrollViewHeight = self.visibleScrollViewHeight(for: size)

        return scrollViewHeight
    }

    func contectHeight(for size: CGSize) -> CGFloat {
        return size.height
    }


    func visibleScrollViewHeight(for size: CGSize) -> CGFloat {

        return 300
    }
}
