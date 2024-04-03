//
//  Keychain.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import KeychainAccess

public extension Keychain {
    static let `default`: Keychain = {
        return .init(server: .init(unsafeString: "https://api.lp1.av5ja.srv.nintendo.net"), protocolType: .https)
    }()

    var configuration: Configuration? {
        let identifier: String = "63f95c5142c5a0bb7ceb137c4663001e01f4fffc4656f50dc033d82d8d4e0cc8"
        let decoder: JSONDecoder = .init()
        guard let data: Data = try? getData(identifier)
        else {
            return nil
        }
        return try? decoder.decode(Configuration.self, from: data)
    }
}
