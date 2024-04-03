//
//  UIDevice.swift
//  Mudmouth
//
//  Created by devonly on 2023/04/01.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import UIKit

public extension UIDevice {
    /// iOSバージョン
    var iOSVersion: String {
        UIDevice.current.systemVersion
    }

    /// ビルド番号
    var buildVersion: Int {
        guard let bundleVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
              let bundleVersion = Int(bundleVersion)
        else {
            return 0
        }
        return bundleVersion
    }

    /// アプリバージョン
    var version: String {
        guard let bundleShortVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        else {
            return "1.0.0"
        }
        return bundleShortVersion
    }

    /// アプリバージョンをUInt64に変換した数値
    var versionId: UInt64 {
        UInt64(version.split(separator: ".").compactMap { Int($0) }.map { String(format: "%02d", $0) }.joined(), radix: 16) ?? 0
    }
}
