//
//  VPNApp.swift
//  VPN
//
//  Created by devonly on 2024/03/24.
//

import SwiftUI
import Mudmouth

@main
struct VPNApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    class AppDelegate: NSObject, UIApplicationDelegate, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {
        func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
        ) -> Bool {
            SwiftyLogger.configure()
            UNUserNotificationCenter.current().delegate = self
            return true
        }

        func application(
            _ application: UIApplication,
            configurationForConnecting connectingSceneSession: UISceneSession,
            options: UIScene.ConnectionOptions
        ) -> UISceneConfiguration {
            let config = UISceneConfiguration(
                name: nil,
                sessionRole: connectingSceneSession.role
            )
            config.delegateClass = AppDelegate.self
            return config
        }

        func scene(
          _ scene: UIScene,
          openURLContexts URLContexts: Set<UIOpenURLContext>
        ) {
            if let url: URL = URLContexts.first?.url {
            }
        }

        func scene(
          _ scene: UIScene,
          willConnectTo session: UISceneSession,
          options connectionOptions: UIScene.ConnectionOptions
        ) {
            if let url = connectionOptions.urlContexts.first?.url {
            }
        }
        
        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
            if let bulletToken: String = response.headers.bulletToken,
               let gameWebToken: String = response.headers.gameWebToken,
               let version: String = response.headers.version
            {
                SwiftyLogger.debug("Version: \(version)")
                SwiftyLogger.debug("BulletToken: \(bulletToken)")
                SwiftyLogger.debug("GameWebToken: \(gameWebToken)")
            }
        }
    }
}
