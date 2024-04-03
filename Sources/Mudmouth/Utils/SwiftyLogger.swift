//
//  SwiftyLogger.swift
//  SplatNet3
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
@_implementationOnly import SwiftyBeaver
#if canImport(UIKit)
import UIKit
#endif

public enum SwiftyLogger {
    private static let logger: SwiftyBeaver.Type = SwiftyBeaver.self
    private static let format: String = "$DHH:mm:ss$d $L: $M"
    private static let manager: FileManager = .default
    private static let baseURL: URL = {
        guard let baseURL: URL = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Find a document directory is failed.")
        }
        return baseURL
            .appendingPathComponent("logs", conformingTo: .directory)
            .appendingPathComponent("swiftybeaver.log", conformingTo: .log)
    }()

    /// 設定
    /// AppDelegateで実行すること
    public static func configure() {
        logger.addDestination(FileDestination(format: SwiftyLogger.format, url: baseURL))
#if DEBUG
        logger.addDestination(ConsoleDestination(format: SwiftyLogger.format))
#endif

        /// 起動時にログ出力
#if canImport(UIKit)
        logger.info("iOS Version: \(UIDevice.current.iOSVersion)")
        logger.info("App Version: \(UIDevice.current.version) \(UIDevice.current.buildVersion)")
        if let uuid: UUID = UIDevice.current.identifierForVendor {
            logger.info("Device UUID: \(uuid.uuidString)")
        }
#endif
    }

    public static func info(_ message: Any, context: Any? = nil) {
        logger.info(message, context: context)
    }

    public static func error(_ message: Any, context: Any? = nil) {
        logger.error(message, context: context)
    }

    public static func debug(_ message: Any, context: Any? = nil) {
        logger.debug(message, context: context)
    }

    public static func warn(_ message: Any, context: Any? = nil) {
        logger.warning(message, context: context)
    }

    public static func verbose(_ message: Any, context: Any? = nil) {
        logger.verbose(message, context: context)
    }

    @discardableResult
    /// ログ削除
    /// - Returns: 成否
    public static func deleteLogFile() -> Bool {
        guard let destination: FileDestination = logger.destinations.compactMap({ $0 as? FileDestination }).first else {
            return false
        }
        return destination.deleteLogFile()
    }
}

extension ConsoleDestination {
    /// コンソールには全て出力
    convenience init(format: String) {
        self.init()
        self.format = format
        minLevel = .verbose
    }
}

extension FileDestination {
    /// ファイルにはInfo以上を出力
    /// - Parameters:
    ///   - format: フォーマット
    ///   - url: 出力先
    convenience init(format: String, url: URL? = nil) {
        self.init()
        self.logFileURL = url
        self.logFileAmount = 10
        self.logFileMaxSize = 1 * 1024 * 1024
        self.format = format
#if DEBUG
        minLevel = .error
#else
        minLevel = .info
#endif
    }
}
