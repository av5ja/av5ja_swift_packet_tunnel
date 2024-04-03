//
//  String.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation

extension String {
    var data: Data {
        Data(hexString: self)
    }

    var bytes: [UInt8] {
        [UInt8](data)
    }
    
    /// 正規表現でマッチングし、合致した文字列をグループを指定して返す
    func capture(pattern: String, group: Int) -> String? {
        capture(pattern: pattern, group: [group]).first
    }

    /// 正規表現でマッチングし、合致した文字列をグループを指定して返す
    func capture(pattern: String, group: [Int]) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        guard let matches = regex.firstMatch(in: self, range: NSRange(location: 0, length: count)) else {
            return []
        }
        return group.map { group -> String in
            // swiftlint:disable:next legacy_objc_type
            (self as NSString).substring(with: matches.range(at: group))
        }
    }

    /// 正規表現でマッチングし、合致した文字列を全て返す
    func capture(pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        let matches: [NSTextCheckingResult] = regex.matches(in: self, range: NSRange(location: 0, length: count))
        return matches.map { match in
            // swiftlint:disable:next legacy_objc_type
            (self as NSString).substring(with: match.range)
        }
    }
}
