//
//  HTTPHeaders.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import NIOHTTP1

extension HTTPHeaders {
    var readable: String {
        var result = ""
        _ = self.map { name, value in
            if !result.isEmpty {
                result.append("\r\n")
            }
            result.append("\(name): \(value)")
        }
        return result
    }
}
