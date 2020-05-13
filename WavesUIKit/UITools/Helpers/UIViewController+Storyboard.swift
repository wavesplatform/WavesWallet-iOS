//
//  UIViewController+Storyboard.swift
//  UITools
//
//  Created by vvisotskiy on 13.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import UIKit

public protocol StoryboardInstantiatable: AnyObject {}

extension StoryboardInstantiatable where Self: UIViewController {
    /// Проинициализирует ViewController по его имени, если он будет указан внутри Storyboard в качестве id
    // TODO: сделать тесты для инициализации всех контроллеров (проверить правильную инициализацию)
    public static func instantiateFromStoryboard() -> Self {
        let bundle = Bundle(for: self)
        let stringName = String(describing: self)
        let storyboard = UIStoryboard(name: stringName, bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: stringName) as! Self
    }
}
