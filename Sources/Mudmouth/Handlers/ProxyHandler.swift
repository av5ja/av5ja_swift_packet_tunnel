//
//  ProxyHandler.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import DequeModule
import Foundation
import NIOCore
import NIOHTTP1
import NIOPosix
import NIOSSL
import OSLog
import SwiftUI

class ProxyHandler: NotificationHandler, ChannelDuplexHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias InboundOut = HTTPClientRequestPart
    typealias OutboundIn = HTTPClientResponsePart
    typealias OutboundOut = HTTPServerResponsePart

    private var url: URL = .init(unsafeString: "https://api.lp1.av5ja.srv.nintendo.net/api/graphql")

    private var requests: Deque<HTTP.Request> = []
    private var response: HTTP.Response?

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let httpData = unwrapInboundIn(data)
        switch httpData {
        case .head(let head):
            requests.append(HTTP.Request(headers: head))
            context.fireChannelRead(wrapInboundOut(.head(head)))
        case .body(let body):
            requests.last!.appendBody(body)
            context.fireChannelRead(wrapInboundOut(.body(.byteBuffer(body))))
        case .end:
            if let request: HTTP.Request = requests.last,
               request.headers.method == .POST,
               request.headers.uri == url.path {
                Task(priority: .background, operation: {
                    try await requestNotification(request: request)
                })
//                let headers: [HTTPHeader] = request.headers.headers.map({ .init(key: $0.name, value: AnyCodable($0.value)) })
//                Task(priority: .background, operation: {
//                    try await requestNotification(headers: headers)
//                })
            }
            context.fireChannelRead(wrapInboundOut(.end(nil)))
        }
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let httpData = unwrapOutboundIn(data)
        switch httpData {
        case .head(let head):
            response = HTTP.Response(headers: head)
            context.write(wrapOutboundOut(.head(head)), promise: promise)
        case .body(let body):
            response!.appendBody(body)
            context.write(wrapOutboundOut(.body(.byteBuffer(body))), promise: promise)
        case .end:
            if let request: HTTP.Request = requests.last,
               request.headers.method == .POST,
               request.headers.uri == url.path {
                Task(priority: .background, operation: {
                    try await requestNotification(request: request)
                })
            }
            response = nil
            context.write(wrapOutboundOut(.end(nil)), promise: promise)
        }
    }

    func channelInactive(context: ChannelHandlerContext) {
    }
}
