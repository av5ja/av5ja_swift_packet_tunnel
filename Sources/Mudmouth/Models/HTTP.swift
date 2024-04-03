//
//  HTTP.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import NIOCore
import NIOHTTP1

enum HTTP {
    class Request {
        var headers: HTTPRequestHead
        var body: Data?

        init(headers: HTTPRequestHead) {
            self.headers = headers
        }

        public func appendBody(_ body: ByteBuffer) {
            if let bytes: [UInt8] = body.getBytes(at: body.readerIndex, length: body.readableBytes) {
                self.body?.append(contentsOf: bytes)
            }
        }
    }

    class Response {
        var headers: HTTPResponseHead
        var body: Data?

        init(headers: HTTPResponseHead) {
            self.headers = headers
        }

        public func appendBody(_ body: ByteBuffer) {
            if let bytes: [UInt8] = body.getBytes(at: body.readerIndex, length: body.readableBytes) {
                self.body?.append(contentsOf: bytes)
            }
        }
    }
}
