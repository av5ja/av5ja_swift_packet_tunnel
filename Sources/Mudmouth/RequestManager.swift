//
//  RequestManager.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import NetworkExtension
import OSLog
import UserNotifications
import SwiftUI
import DequeModule
import NIOCore
import NIOHTTP1
import NIOPosix
import NIOSSL

internal class RequestManager: CertificateManager {
    @Published var provider: NETunnelProviderManager?
    private let bundleIdentifier: String = "\(Bundle.main.bundleIdentifier!).PacketTunnel"

    override init() {
        super.init()
    }

    @MainActor
    @discardableResult
    /// VPN設定を作成して保存する
    /// - Returns: VPN設定
    func saveToPreferences() async throws -> NETunnelProviderManager? {
        let granted: Bool = try await requestAuthorization()
        if !granted {
            return nil
        }
        let manager: NETunnelProviderManager = .init()
        manager.localizedDescription = "@Salmonia3JP"
        let proto: NETunnelProviderProtocol = .init()
        proto.providerBundleIdentifier = bundleIdentifier
        proto.serverAddress = "Salmonia3"
        manager.protocolConfiguration = proto
        manager.isEnabled = true
        try await manager.saveToPreferences()
        return manager
    }

    @MainActor
    /// 保存されているVPN設定を読み込む
    func loadAllFromPreferences() async throws {
        // 一件もなければ何もしない
        guard let provider: NETunnelProviderManager = try await NETunnelProviderManager.loadAllFromPreferences().first
        else {
            return
        }
        self.provider = provider
        return
    }

    /// VPNサーバー起動
    /// - Parameters:
    ///   - provider: <#provider description#>
    ///   - configuration: <#configuration description#>
    ///   - completion: <#completion description#>
    @MainActor
    func startVPNTunnel() async throws {
        guard let provider: NETunnelProviderManager = provider
        else {
            try await loadAllFromPreferences()
            return
        }
        let encoder: JSONEncoder = .init()
        provider.isEnabled = true
        try await provider.saveToPreferences()
        let data: Data = try encoder.encode(configuration.generate())
        try provider.connection.startVPNTunnel(options: [
            NEVPNConnectionStartOptionPassword: data as NSObject
        ])
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        await UIApplication.shared.open(.init(unsafeString: "com.nintendo.znca://znca/game/4834290508791808"))
    }

    /// VPNサーバー停止
    @MainActor
    func stopVPNTunnel() {
        provider?.connection.stopVPNTunnel()
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    private func requestAuthorization() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert])
    }
}
