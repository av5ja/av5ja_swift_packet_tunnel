//
//  MITMServer.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import NetworkExtension
import DequeModule
import CryptoKit
import Foundation
import NIOCore
import NIOHTTP1
import NIOPosix
import NIOSSL
import OSLog
import KeychainAccess

public func startMITMServer(configuration: Configuration) async throws {
    let url: URL = .init(unsafeString: "https://api.lp1.av5ja.srv.nintendo.net/api/graphql")
    let keychain: Keychain = .default
    guard let configuration = keychain.configuration
    else {
        return
    }
    // Process packets in the tunnel.
    let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    return try await withCheckedThrowingContinuation({ continuation in
        ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.backlog, value: 256)
            .serverChannelOption(ChannelOptions.socket(SOL_SOCKET, SO_REUSEADDR), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.addHandler(ByteToMessageHandler(HTTPRequestDecoder(leftOverBytesStrategy: .forwardBytes)))
                    .flatMap { _ in
                        channel.pipeline.addHandler(HTTPResponseEncoder())
                    }
                    .flatMap { _ in
                        channel.pipeline.addHandler(ConnectHandler())
                    }
                    .flatMap { _ in
                        channel.pipeline.addHandler(NIOSSLServerHandler(context: configuration.context))
                    }
                    .flatMap { _ in
                        channel.pipeline.addHandler(ByteToMessageHandler(HTTPRequestDecoder(leftOverBytesStrategy: .forwardBytes)))
                    }
                    .flatMap { _ in
                        channel.pipeline.addHandler(HTTPResponseEncoder())
                    }
                    .flatMap { _ in
                        channel.pipeline.addHandler(ProxyHandler())
                    }
            }
            .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
            .childChannelOption(ChannelOptions.socket(SOL_SOCKET, SO_REUSEADDR), value: 1)
            .bind(host: "127.0.0.1", port: 6836)
            .whenComplete { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let failure):
                    SwiftyLogger.error(failure)
                    continuation.resume(throwing: failure)
                }
            }
    })
}
