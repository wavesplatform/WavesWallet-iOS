//
//  ConfirmRequestModuleOutput.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.08.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation
import DomainLayer
import RxSwift

protocol ConfirmRequestModuleOutput: AnyObject {
    
    func confirmRequestDidTapReject(_ complitingRequest: ConfirmRequest.DTO.ComplitingRequest)
    func confirmRequestDidTapApprove(_ complitingRequest: ConfirmRequest.DTO.ComplitingRequest)
}
