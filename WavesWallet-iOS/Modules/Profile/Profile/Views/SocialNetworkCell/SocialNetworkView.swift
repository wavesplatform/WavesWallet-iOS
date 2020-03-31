//
//  SocialNetworkView.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 31.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Extensions
import RxCocoa
import RxSwift
import UIKit

final class SocialNetworkCell: UITableViewXibContainerCell<SocialNetworkView> {
    override func initialSetup() {
        selectionStyle = .none
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        view.resetToEmptyState()
    }
}

final class SocialNetworkView: UIView, NibLoadable, ResetableView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var telegramButton: UIButton!
    @IBOutlet private weak var mediumButton: UIButton!
    @IBOutlet private weak var twitterButton: UIButton!

    private let disposeBag = DisposeBag()

    private var didTapTelegram: VoidClosure?
    private var didTapMedium: VoidClosure?
    private var didTapTwitter: VoidClosure?

    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }

    func resetToEmptyState() {
        titleLabel.text = nil
        
        didTapTelegram = nil
        didTapMedium = nil
        didTapTwitter = nil
    }

    func setTitle(_ text: String,
                  didTapTelegram: @escaping VoidClosure,
                  didTapMedium: @escaping VoidClosure,
                  didTapTwitter: @escaping VoidClosure) {
        titleLabel.text = text
        self.didTapTelegram = didTapTelegram
        self.didTapMedium = didTapMedium
        self.didTapTwitter = didTapTwitter
    }

    private func initialSetup() {
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        titleLabel.textColor = .basic500

        telegramButton.setTitle(nil, for: .normal)
        telegramButton.setImage(Images.menuTel.image, for: .normal)
        telegramButton.rx
            .tap
            .subscribe(onNext: { [weak self] in self?.didTapTelegram?() })
            .disposed(by: disposeBag)

        mediumButton.setTitle(nil, for: .normal)
        mediumButton.setImage(Images.medium28.image, for: .normal)
        mediumButton.rx
            .tap
            .subscribe(onNext: { [weak self] in self?.didTapMedium?() })
            .disposed(by: disposeBag)

        twitterButton.setTitle(nil, for: .normal)
        twitterButton.setImage(Images.menuTwitter.image, for: .normal)
        twitterButton.rx
            .tap
            .subscribe(onNext: { [weak self] in self?.didTapTwitter?() })
            .disposed(by: disposeBag)
    }
}
