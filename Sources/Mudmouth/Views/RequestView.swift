//
//  RequestView.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import SwiftUI
import OSLog
import NetworkExtension

public struct RequestButton: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var manager: RequestManager = .init()
    @State private var status: NEVPNStatus = .invalid

    public init() {}

    public var body: some View {
        StartCapture()
            .onChange(of: scenePhase, perform: { newValue in
                if newValue == .active {
                    Task(priority: .medium, operation: {
                        try await manager.loadAllFromPreferences()
                    })
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: .NEVPNStatusDidChange), perform: { newValue in
                // VPNの接続が変わったときにステータスを変更する
                if let object: NETunnelProviderSession = newValue.object as? NETunnelProviderSession {
                    status = object.status
                }
            })
            .onReceive(NotificationCenter.default.publisher(for: .NEVPNConfigurationChange), perform: { newValue in
                // VPNの設定が更新されたときに切り替える
                if let object: NETunnelProviderManager = newValue.object as? NETunnelProviderManager {
                    manager.provider = object
                }
            })
    }

    @ViewBuilder
    // swiftlint:disable:next identifier_name
    func StartCapture() -> some View {
        switch status {
        case .invalid:
            Button(action: {
                Task(priority: .background, operation: {
                    try await manager.saveToPreferences()
                })
            }, label: {
                Text("Install")
            })
        case .disconnected:
            Button(action: {
                Task(priority: .medium, operation: {
                    try await manager.startVPNTunnel()
                })
            }, label: {
                Text("Connect")
            })
        case .connecting:
            Button(action: {}, label: {
                Text("Connecting")
            })
            .disabled(true)
        case .connected:
            Button(action: {
                Task(priority: .medium, operation: {
                    manager.stopVPNTunnel()
                })
            }, label: {
                Text("Disconnect")
            })
        case .reasserting:
            Button(action: {}, label: {
                Text("Reasserting")
            })
            .disabled(true)
        case .disconnecting:
            Button(action: {}, label: {
                Text("Disconnecting")
            })
            .disabled(true)
        @unknown default:
            fatalError("Unknown Status Value")
        }
    }
}

#Preview {
    RequestButton()
}
