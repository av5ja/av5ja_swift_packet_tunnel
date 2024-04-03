//
//  NotificationHandler.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import UserNotifications
import NIOHTTP1

internal class NotificationHandler {
    @MainActor
    func requestNotification(request: HTTP.Request) async throws {
        let content: UNMutableNotificationContent = .init()
        content.title = "Request Captured"
        content.body = "Please press the notification to continue in Mudmouth"
        let headers: SP3Headers = request.headers.headers.compactMap({ .init(key: $0.name, value: $0.value) })
        SwiftyLogger.debug(headers)
        content.userInfo = [
            "headers": headers.base64EncodedString
        ]
        let triger: UNTimeIntervalNotificationTrigger = .init(timeInterval: 1, repeats: false)
        let request: UNNotificationRequest = .init(identifier: UUID().uuidString, content: content, trigger: triger)
        try await UNUserNotificationCenter.current().add(request)
    }
}

extension HTTPHeaders: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let body: [String: String] = reduce(into: [:], { $0[$1.name] = $1.value })
        try container.encode(body)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let headers: [(String, String)] = try container.decode([String: String].self).map({ ($0.key, $0.value) })
        self.init(headers)
    }
    
    public var base64EncodedString: String {
        let encoder: JSONEncoder = .init()
        // swiftlint:disable:next force_try
        let data: Data = try! encoder.encode(self)
        return data.base64EncodedString()
    }
}
