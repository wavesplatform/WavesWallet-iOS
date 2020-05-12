//
//  UITableView+Reusable.swift
//  UITools
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import UIKit

public extension UITableView {
    func registerHeaderFooter<HeaderFooter>(type: HeaderFooter.Type)
        where HeaderFooter: UITableViewHeaderFooterView & NibReusable {
        register(HeaderFooter.nib, forHeaderFooterViewReuseIdentifier: HeaderFooter.reuseIdentifier)
    }

    func registerHeaderFooter<HeaderFooter>(type: HeaderFooter.Type)
        where HeaderFooter: UITableViewHeaderFooterView & Reusable {
        register(type, forHeaderFooterViewReuseIdentifier: HeaderFooter.reuseIdentifier)
    }

    func dequeueHeaderFooter<HeaderFooter>() -> HeaderFooter
        where HeaderFooter: UITableViewHeaderFooterView & Reusable {
        return dequeueReusableHeaderFooterView(withIdentifier: HeaderFooter.reuseIdentifier) as! HeaderFooter
    }

    func dequeueAndRegisterHeaderFooter<HeaderFooter>() -> HeaderFooter
        where HeaderFooter: UITableViewHeaderFooterView & NibReusable {
        if let headerFooter = dequeueReusableHeaderFooterView(withIdentifier: HeaderFooter.reuseIdentifier) as? HeaderFooter {
            return headerFooter
        } else {
            register(HeaderFooter.nib, forHeaderFooterViewReuseIdentifier: HeaderFooter.reuseIdentifier)
            return dequeueReusableHeaderFooterView(withIdentifier: HeaderFooter.reuseIdentifier) as! HeaderFooter
        }
    }

    func dequeueAndRegisterHeaderFooter<HeaderFooter>() -> HeaderFooter
        where HeaderFooter: UITableViewHeaderFooterView & Reusable {
        if let headerFooter = dequeueReusableHeaderFooterView(withIdentifier: HeaderFooter.reuseIdentifier) as? HeaderFooter {
            return headerFooter
        } else {
            register(HeaderFooter.self, forHeaderFooterViewReuseIdentifier: HeaderFooter.reuseIdentifier)
            return dequeueReusableHeaderFooterView(withIdentifier: HeaderFooter.reuseIdentifier) as! HeaderFooter
        }
    }
}

// MARK: - Register and dequeue cell

public extension UITableView {
    func registerCell<Cell>(type: Cell.Type) where Cell: UITableViewCell & NibReusable {
        register(Cell.nib, forCellReuseIdentifier: Cell.reuseIdentifier)
    }

    func registerCell<Cell>(type: Cell.Type)
        where Cell: UITableViewCell & Reusable {
        register(type, forCellReuseIdentifier: Cell.reuseIdentifier)
    }

    func dequeueCell<Cell>() -> Cell where Cell: UITableViewCell & Reusable {
        return dequeueReusableCell(withIdentifier: Cell.reuseIdentifier) as! Cell
    }

    func dequeueCellForIndexPath<Cell>(indexPath: IndexPath) -> Cell where Cell: UITableViewCell & Reusable {
        return dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }

    func dequeueAndRegisterCell<Cell>() -> Cell where Cell: UITableViewCell & NibReusable {
        if let cell = dequeueReusableCell(withIdentifier: Cell.reuseIdentifier) as? Cell {
            return cell
        } else {
            register(Cell.nib, forCellReuseIdentifier: Cell.reuseIdentifier)
            return dequeueReusableCell(withIdentifier: Cell.reuseIdentifier) as! Cell
        }
    }

    func dequeueAndRegisterCell<Cell>() -> Cell where Cell: UITableViewCell & Reusable {
        if let cell = dequeueReusableCell(withIdentifier: Cell.reuseIdentifier) as? Cell {
            return cell
        } else {
            register(Cell.self, forCellReuseIdentifier: Cell.reuseIdentifier)
            return dequeueReusableCell(withIdentifier: Cell.reuseIdentifier) as! Cell
        }
    }

    func dequeueAndRegisterCell<Cell>(indexPath: IndexPath) -> Cell where Cell: UITableViewCell & NibReusable {
        register(Cell.nib, forCellReuseIdentifier: Cell.reuseIdentifier)
        return dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }

    func dequeueAndRegisterCell<Cell>(indexPath: IndexPath) -> Cell where Cell: UITableViewCell & Reusable {
        register(Cell.self, forCellReuseIdentifier: Cell.reuseIdentifier)
        return dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
    }
}

