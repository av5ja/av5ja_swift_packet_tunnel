//
//  UNNotificationResponse.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import UserNotifications

public extension UNNotificationResponse {
    var headers: SP3Headers {
        guard let headers: String = notification.request.content.userInfo["headers"] as? String,
              let data: Data = Data(base64Encoded: headers)
        else {
            return []
        }
        let decoder: JSONDecoder = .init()
        // swiftlint:disable:next force_try force_unwrapping
        return try! decoder.decode(SP3Headers.self, from: data)
    }
}
