import XCTest
import CryptoKit
@testable import X509
@testable import Mudmouth
@testable import SwiftASN1

enum KeyPathType: String, CaseIterable {
    case PrivateKey
    case Certificate
}

func getPEMString<T: BinaryInteger>(path: T, keyPath: KeyPathType) -> String {
    let target: String = .init(format: "%02d", UInt8(path))
    guard let url: URL = Bundle.module.url(forResource: target, withExtension: "txt", subdirectory: "Data/\(keyPath.rawValue)"),
          let data: Data = try? .init(contentsOf: url),
          let stringValue: String = .init(data: data, encoding: .utf8)
    else {
        fatalError()
    }
    return stringValue.trimmingCharacters(in: .newlines)
}

final class PacketCaptureTests: XCTestCase {
    let manager: CertificateManager = .init()

    func testRootKeychain() throws {
        let decoder: JSONDecoder = .init()
        let encoder: JSONEncoder = .init()
        let configuration: Configuration = .default
        let data: Data = try encoder.encode(configuration)
        let verifier: Configuration = try decoder.decode(Configuration.self, from: data)
        XCTAssertEqual(configuration.privateKey.derBytes, verifier.privateKey.derBytes)
        XCTAssertEqual(configuration.certificate.derBytes, verifier.certificate.derBytes)
        XCTAssertEqual(configuration.certificate.pemRepresentation, verifier.certificate.pemRepresentation)
        XCTAssertTrue(configuration.isValid)
        XCTAssertTrue(verifier.isValid)
    }

    func testCAKeychain() throws {
        let decoder: JSONDecoder = .init()
        let encoder: JSONEncoder = .init()
        let configuration: Configuration = {
            let configuration: Configuration = .default
            return configuration.generate()
        }()
        let data: Data = try encoder.encode(configuration)
        let verifier: Configuration = try decoder.decode(Configuration.self, from: data)
        XCTAssertEqual(configuration.privateKey.derBytes, verifier.privateKey.derBytes)
        XCTAssertEqual(configuration.certificate.derBytes, verifier.certificate.derBytes)
        XCTAssertEqual(configuration.certificate.pemRepresentation, verifier.certificate.pemRepresentation)
        XCTAssertTrue(configuration.isValid)
        XCTAssertTrue(verifier.isValid)
    }

    func testPrivateKeyPEMString() throws {
        try [1, 2].forEach({ (index: UInt8) in
            let privateKeyPEMString: String = getPEMString(path: index, keyPath: .PrivateKey)
            let privateKey: P256.Signing.PrivateKey = try .init(pemRepresentation: privateKeyPEMString)
            let certificatePrivateKey: Certificate.PrivateKey = .init(privateKey)
            XCTAssertEqual(privateKey.pemRepresentation, privateKeyPEMString)
            XCTAssertEqual(certificatePrivateKey.publicKey.pemRepresentation, privateKey.publicKey.pemRepresentation)
            XCTAssertEqual(certificatePrivateKey.pemRepresentation, privateKey.pemRepresentation)
            XCTAssertEqual(certificatePrivateKey.derRepresentation, privateKey.derRepresentation)
        })
    }

    func testCertificatePEMString() throws {
        try [1, 2].forEach({ (index: UInt8) in
            let certificatePEMString: String = getPEMString(path: index, keyPath: .Certificate)
            let certificate: Certificate = try .init(pemEncoded: certificatePEMString)
            XCTAssertEqual(certificate.pemRepresentation, certificatePEMString)
        })
    }

    func testCertificate() throws {
        let configuration: Configuration = .default
        let verifier: Configuration = .default
        XCTAssertEqual(configuration.privateKey.derBytes, verifier.privateKey.derBytes)
        XCTAssertEqual(configuration.certificate.derBytes, verifier.certificate.derBytes)
        print(configuration.certificate)
    }

    func testCACertificate() throws {
        let configuration: Configuration = {
            let configuration: Configuration = .default
            return configuration.generate()
        }()
        let verifier: Configuration = {
            let configuration: Configuration = .default
            return configuration.generate()
        }()
        XCTAssertEqual(configuration.privateKey.derBytes, verifier.privateKey.derBytes)
        XCTAssertEqual(configuration.certificate.subject, verifier.certificate.subject)
        XCTAssertEqual(configuration.certificate.extensions, verifier.certificate.extensions)
        XCTAssertEqual(configuration.certificate.notValidAfter, verifier.certificate.notValidAfter)
        XCTAssertEqual(configuration.certificate.notValidBefore, verifier.certificate.notValidBefore)
        XCTAssertEqual(configuration.certificate.publicKey.pemRepresentation, verifier.certificate.publicKey.pemRepresentation)
        XCTAssertEqual(configuration.certificate.issuer, verifier.certificate.issuer)
        XCTAssertEqual(configuration.certificate.serialNumber, verifier.certificate.serialNumber)
        XCTAssertEqual(configuration.certificate.signatureAlgorithm, verifier.certificate.signatureAlgorithm)
        XCTAssertEqual(configuration.certificate.version, verifier.certificate.version)
        XCTAssertEqual(configuration.certificate.tbsCertificate, verifier.certificate.tbsCertificate)
    }

    func testPrivateKeyCertificatePEMString() throws {
        try [1, 2].forEach({ (index: UInt8) in
            let privateKeyPEMString: String = getPEMString(path: index, keyPath: .PrivateKey)
            let certificatePEMString: String = getPEMString(path: index, keyPath: .Certificate)
            let privateKey: Certificate.PrivateKey = try .init(pemRepresentation: privateKeyPEMString)
            let certificate: Certificate = try .init(pemEncoded: certificatePEMString)
            XCTAssertEqual(certificate.publicKey.pemRepresentation, privateKey.publicKey.pemRepresentation)
        })
    }

    func testGenerate() throws {
        try (0..<100).forEach({ _ in
            let configuration: Configuration = manager.generate()
            XCTAssertTrue(configuration.isValid)
        })
        let configuration: Configuration = .default
        let certificatePEMString: String = getPEMString(path: 1, keyPath: .Certificate)
        let certificate: Certificate = try .init(pemEncoded: certificatePEMString)
        XCTAssertEqual(configuration.certificate.subject, certificate.subject)
        XCTAssertEqual(configuration.certificate.extensions, certificate.extensions)
        XCTAssertEqual(configuration.certificate.notValidAfter, certificate.notValidAfter)
        XCTAssertEqual(configuration.certificate.notValidBefore, certificate.notValidBefore)
        XCTAssertEqual(configuration.certificate.publicKey.pemRepresentation, certificate.publicKey.pemRepresentation)
        XCTAssertEqual(configuration.certificate.issuer, certificate.issuer)
        XCTAssertEqual(configuration.certificate.serialNumber, certificate.serialNumber)
        XCTAssertEqual(configuration.certificate.signatureAlgorithm, certificate.signatureAlgorithm)
        XCTAssertEqual(configuration.certificate.version, certificate.version)
        XCTAssertEqual(configuration.certificate.tbsCertificate, certificate.tbsCertificate)
    }

    func testCAGenerate() throws {
        try (0..<100).forEach({ _ in
            let configuration: Configuration = {
                let configuration: Configuration = manager.generate()
                return configuration.generate()
            }()
            XCTAssertTrue(configuration.isValid)
        })
        let configuration: Configuration = {
            let configuration: Configuration = .default
            return configuration.generate()
        }()
        let certificatePEMString: String = getPEMString(path: 2, keyPath: .Certificate)
        let certificate: Certificate = try .init(pemEncoded: certificatePEMString)
        XCTAssertEqual(configuration.certificate.subject, certificate.subject)
        XCTAssertEqual(configuration.certificate.extensions, certificate.extensions)
        XCTAssertEqual(configuration.certificate.notValidAfter, certificate.notValidAfter)
        XCTAssertEqual(configuration.certificate.notValidBefore, certificate.notValidBefore)
        XCTAssertEqual(configuration.certificate.publicKey.pemRepresentation, certificate.publicKey.pemRepresentation)
        XCTAssertEqual(configuration.certificate.issuer, certificate.issuer)
        XCTAssertEqual(configuration.certificate.serialNumber, certificate.serialNumber)
        XCTAssertEqual(configuration.certificate.signatureAlgorithm, certificate.signatureAlgorithm)
        XCTAssertEqual(configuration.certificate.version, certificate.version)
        XCTAssertEqual(configuration.certificate.tbsCertificate, certificate.tbsCertificate)
    }

    func testCertificateSerialize() throws {
        try (0..<10).forEach({ _ in
            var serializer: DER.Serializer = .init()
            let configuration: Configuration = .default
            try serializer.serialize(configuration.certificate)
            XCTAssertEqual(configuration.certificate.derBytes, serializer.serializedBytes)
            XCTAssertTrue(configuration.isValid)
        })
    }
}
