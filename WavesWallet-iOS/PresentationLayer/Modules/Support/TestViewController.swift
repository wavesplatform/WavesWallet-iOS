//
//  TestViewController.swift
//  
//
//  Created by mefilt on 31/01/2019.
//

import Foundation
import UIKit

final class TestViewController: ModalScrollViewController {

    @IBOutlet var tableView: ModalTableView!

    private var needUpdateInsets: Bool = true

    private var languages: [Language] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        var newList = Language.list
        newList.append(contentsOf: Language.list)

        let number = Int.random(in: 0..<newList.count)
        self.languages = newList
        self.tableView.reloadData()

        tableView.backgroundModalView.backgroundColor = .white
        self.tableView.shouldPassthroughTouch = true
        self.tableView.isEnabledPassthroughSubviews = true
    }

    override var scrollView: UIScrollView {
        return self.tableView
    }

    override func visibleScrollViewHeight(for size: CGSize) -> CGFloat {
        return 500
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
}

