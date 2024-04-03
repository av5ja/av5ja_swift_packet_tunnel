//
//  Certificate.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import Foundation
import X509
import CryptoKit

public extension Certificate {
    var derRepresentation: Data {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().derBytes.data
    }

    var pemRepresentation: String {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().pemString
    }

    ///
    var derBytes: [UInt8] {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().derBytes
    }

    func verify(privateKey key: Certificate.PrivateKey) -> Bool {
        key.publicKey == publicKey
    }

    func verify(publicKey key: Certificate.PublicKey) -> Bool {
        key == publicKey
    }
}

public extension Certificate.PrivateKey {
    var pemRepresentation: String {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().pemString
    }

    var derBytes: [UInt8] {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().derBytes
    }

    var derRepresentation: Data {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().derBytes.data
    }

    /// Root PrivateKey
    static let root: Certificate.PrivateKey = {
        #if targetEnvironment(simulator)
        let privateKeyPEMString: String =
"""
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgebdLCI/Si8R6k282
5tFoH9UyDIerZwv9iG6gTER3esahRANCAAQ8KR9dvGmnMEYHQimWxlyLV7OthoM1
GC36kl0n1ts2OBvRSDcuzrLRi4dKIOpASth1gRAf3TeC4NoQ9qOxIvZA
-----END PRIVATE KEY-----
"""
        // swiftlint:disable:next force_try
        return .init(try! P256.Signing.PrivateKey(pemRepresentation: privateKeyPEMString))
        #else
        let privateKeyPEMString: String =
"""
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgebdLCI/Si8R6k282
5tFoH9UyDIerZwv9iG6gTER3esahRANCAAQ8KR9dvGmnMEYHQimWxlyLV7OthoM1
GC36kl0n1ts2OBvRSDcuzrLRi4dKIOpASth1gRAf3TeC4NoQ9qOxIvZA
-----END PRIVATE KEY-----
"""
        // swiftlint:disable:next force_try
        return .init(try! P256.Signing.PrivateKey(pemRepresentation: privateKeyPEMString))
//        return .init(P256.Signing.PrivateKey())
        #endif
    }()

    /// CA PrivateKey
    static let site: Certificate.PrivateKey = {
        #if targetEnvironment(simulator)
        let privateKeyPEMString: String =
"""
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg9yRSy6XXcQVEMrSI
hoAgExiGX5YpfgiMsFZdzj8ag7ShRANCAAQG9Q86iDXBT8ES1VesUSItUU09G1UX
61d7YmIXSHt8fiMLHfOr5VUAerlwt9KbRQYfZ2dOlHeU6vzyfoRBJv72
-----END PRIVATE KEY-----
"""
        // swiftlint:disable:next force_try
        return .init(try! P256.Signing.PrivateKey(pemRepresentation: privateKeyPEMString))
        #else
        let privateKeyPEMString: String =
"""
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg9yRSy6XXcQVEMrSI
hoAgExiGX5YpfgiMsFZdzj8ag7ShRANCAAQG9Q86iDXBT8ES1VesUSItUU09G1UX
61d7YmIXSHt8fiMLHfOr5VUAerlwt9KbRQYfZ2dOlHeU6vzyfoRBJv72
-----END PRIVATE KEY-----
"""
        // swiftlint:disable:next force_try
        return .init(try! P256.Signing.PrivateKey(pemRepresentation: privateKeyPEMString))
//        return .init(P256.Signing.PrivateKey())
        #endif
    }()

    init(pemRepresentation: String) throws {
        self.init(try P256.Signing.PrivateKey(pemRepresentation: pemRepresentation))
    }
}

public extension Certificate.PublicKey {
    var pemRepresentation: String {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().pemString
    }

    var derBytes: [UInt8] {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().derBytes
    }

    var derRepresentation: Data {
        // swiftlint:disable:next force_try
        try! serializeAsPEM().derBytes.data
    }
}
