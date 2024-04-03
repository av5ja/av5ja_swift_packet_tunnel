//
//  PrivateKey.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import CryptoKit
import X509

public extension P256.Signing.PrivateKey {
    var derBytes: [UInt8] {
        derRepresentation.bytes
    }

    init(hexString: String) throws {
        try self.init(rawRepresentation: hexString.bytes)
    }
}
