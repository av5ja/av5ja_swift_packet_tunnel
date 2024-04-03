//
//  Data.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation

public extension Data {
    init(buffer: [UInt8]) {
        var tmp: [UInt8] = buffer
        self.init(referencing: NSData(bytes: &tmp, length: tmp.count))
    }

    init(hexString: String) {
        let capacity: Int = hexString.count >> 1
        self.init(capacity: capacity)
        var iterator: String.Iterator = hexString.makeIterator()
        for _ in 0 ..< capacity {
            guard let prefix: Character = iterator.next(),
                  let suffix: Character = iterator.next(),
                  var byte: UInt8 = .init("\(prefix)\(suffix)", radix: 0x10)
            else {
                fatalError("")
            }
            append(&byte, count: 1)
        }
    }

    var bytes: [UInt8] {
        [UInt8](self)
    }

    var hexString: String {
        map({ String(format: "%02X", $0) }).joined()
    }

    var stringValue: String? {
        String(data: self, encoding: .utf8)
    }
}
