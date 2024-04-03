//
//  CertificateManager.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import KeychainAccess
import Crypto
import SwiftASN1
import X509
import NIOHTTP1
import NIO
import OSLog

internal class CertificateManager: ObservableObject {
    private let keychain: Keychain = .default
    private let identifier: String = "915e446bc2893bf7bd938deb9fc211fa16cdc19116c5af4d054cf75ee39ff425"

    @Published var configuration: Configuration!

    init() {
        self.configuration = load(key: identifier)
    }

    /// ルート証明書作成
    /// - Returns: 証明書
    @discardableResult
    func generate() -> Configuration {
        let encoder: JSONEncoder = .init()
        let configuration: Configuration = .default
        // swiftlint:disable:next force_try
        let data: Data = try! encoder.encode(configuration)
        #if !targetEnvironment(simulator)
        // swiftlint:disable:next force_try
        try! keychain.set(data, key: identifier)
        #endif
        self.configuration = configuration
        return configuration
    }

    /// 証明書を読み込み、なければ作成する
    /// - Returns: 証明書
    private func load(key identifier: String) -> Configuration {
        keychain.configuration ?? generate()
    }

    public func removeAll() throws {
        try keychain.removeAll()
    }

    /// 証明書をインストールするためのサーバー
    func launch() {
        // Run in background thread to avoid performance warning, also see https://github.com/apple/swift-nio/issues/2223.
        DispatchQueue.global(qos: .background).async {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            let bootstrap = ServerBootstrap(group: group)
                .serverChannelOption(ChannelOptions.socket(SOL_SOCKET, SO_REUSEADDR), value: 1)
                .childChannelOption(ChannelOptions.socket(SOL_SOCKET, SO_REUSEADDR), value: 1)
                .childChannelInitializer({ channel in
                    channel.pipeline.configureHTTPServerPipeline()
                        .flatMap { _ in
                            channel.pipeline.addHandler(self)
                        }
                })

            // swiftlint:disable:next force_try
            bootstrap.bind(to: try! SocketAddress(ipAddress: "127.0.0.1", port: 8888))
                .whenComplete { result in
                switch result {
                case .success:
                    break
                case .failure(let failure):
                    SwiftyLogger.error(failure)
                }
            }
        }
    }
}

extension CertificateManager: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let httpData = unwrapInboundIn(data)
        guard case .head = httpData else {
            return
        }
        let pemString: String = configuration.certificate.pemRepresentation
        let headers: HTTPHeaders = .init([
            ("Content-Length", pemString.count.formatted()),
            ("Content-Type", "application/x-x509-ca-cert")
        ])
        let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: .ok, headers: headers)
        context.write(wrapOutboundOut(.head(head)), promise: nil)
        let buffer: ByteBuffer = context.channel.allocator.buffer(string: pemString)
        let body: HTTPServerResponsePart = .body(.byteBuffer(buffer))
        context.writeAndFlush(wrapOutboundOut(body), promise: nil)
    }
}

fileprivate extension String {
    // Referenced from https://stackoverflow.com/a/57289245.
    func components(withMaxLength length: Int) -> [String] {
        return stride(from: 0, to: count, by: length).map { offsetBy in
            let start = index(startIndex, offsetBy: offsetBy)
            let end = index(start, offsetBy: length, limitedBy: endIndex) ?? endIndex
            return String(self[start..<end])
        }
    }
}
