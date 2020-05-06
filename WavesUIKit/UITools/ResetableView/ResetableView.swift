//
//  ResetableView.swift
//  UITools
//
//  Created by vvisotskiy on 06.05.2020.
//  Copyright © 2020 WAVES PLATFORM LTD. All rights reserved.
//

import Foundation

/// Протокол предназначен для сбрасывания View к исходному состоянию
public protocol ResetableView: AnyObject {
    func resetToEmptyState()
}
