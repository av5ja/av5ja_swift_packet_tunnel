//
//  Date.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation

extension Date {
    /// 2024-01-01T00:00:00
    static var `default`: Date {
#if targetEnvironment(simulator)
        .init(timeIntervalSince1970: 1704034800)
#else
        .init()
#endif
    }
}
