//
//  SerialNumber.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import X509

extension Certificate.SerialNumber {
    static let `default`: Certificate.SerialNumber = {
#if targetEnvironment(simulator)
        .init(bytes: [185, 121, 99, 172, 224, 189, 8, 9, 69, 150, 227, 39, 214, 49, 227, 209, 221, 75, 3, 64])
#else
        .init()
#endif
    }()
}
