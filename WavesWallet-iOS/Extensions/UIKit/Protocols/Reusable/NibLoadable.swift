//
//  NibLoadable.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 11.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import UIKit

public protocol NibLoadable: AnyObject {
    static var nibName: String { get }
    static var nib: UINib { get }
    static func loadFromNib() -> Self
}

public extension NibLoadable {
    static var nibName: String {
        return String(describing: self)
    }

    static var nib: UINib {
        return UINib(nibName: nibName, bundle: Bundle(for: self))
    }

    static func loadFromNib() -> Self {
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("The nib \(nib) expected its root view to be of type \(self)")
        }
        return view
    }
}

public extension NibLoadable where Self: Reusable {
    static var nibName: String {
        return reuseIdentifier
    }
}

public typealias NibReusable = Reusable & NibLoadable
