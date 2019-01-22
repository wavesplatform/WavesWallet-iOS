//
//  RxDataSource+TableView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 11.07.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation
import RxDataSources

typealias ConfigureCell<S: SectionModelType> = (TableViewSectionedDataSource<S>, UITableView, IndexPath, S.Item) -> UITableViewCell
