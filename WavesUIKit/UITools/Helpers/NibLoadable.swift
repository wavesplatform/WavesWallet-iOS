//
//  NibLoadable.swift
//  UITools
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import UIKit

public protocol NibLoadable: AnyObject {
    static var nibName: String { get }
    static var nib: UINib { get }
    static func loadFromNib() -> Self
}

public extension NibLoadable {
    static var nibName: String {
        String(describing: self)
    }
    
    static var nib: UINib {
        UINib(nibName: nibName, bundle: Bundle(for: self))
    }
    
    static func loadFromNib() -> Self {
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("The nib \(nib) expected its root view to be of type \(self)")
        }
        return view
    }
}

public extension NibLoadable where Self: UIView {
    static func loadFromNib() -> Self {
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("The nib \(nib) expected its root view to be of type \(self)")
        }
        return view
    }
}

public extension NibLoadable where Self: UIViewController {
    
    static func loadFromNib() -> Self {
        return Self.init(nibName: nibName, bundle: Bundle(for: self))
    }
}

public extension NibLoadable where Self: Reusable {
    static var nibName: String {
        reuseIdentifier
    }
}

public typealias NibReusable = Reusable & NibLoadable
