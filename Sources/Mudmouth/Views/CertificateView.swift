//
//  CertificateView.swift
//  Mudmouth
//
//  Created by devonly on 2022/11/26.
//  Copyright © 2023 Magi, Corporation. All rights reserved.
//

import SwiftUI

public struct CertificateView: View {
    @StateObject private var manager: CertificateManager = .init()
    @State private var isPresented: Bool = false
    public init() {}

    public var body: some View {
        NavigationView(content: {
            Form(content: {
                Section(content: {
                    HStack(content: {
                        Text("Organization")
                        Spacer()
                        Text(manager.configuration.issuer)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                    })
                    HStack(content: {
                        Text("Common Name")
                        Spacer()
                        Text(manager.configuration.subject)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                    })
                }, header: {
                    Text("Common")
                })
                Section(content: {
                    HStack(content: {
                        Text("Not Valid Before")
                        Spacer()
                        Text(manager.configuration.notValidBefore, format: .dateTime)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    })
                    HStack(content: {
                        Text("Not Valid After")
                        Spacer()
                        Text(manager.configuration.notValidAfter, format: .dateTime)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    })
                }, header: {
                    Text("Validity period")
                })
                Section(content: {
                    HStack(content: {
                        Text("Algorithm")
                        Spacer()
                        Text(manager.configuration.algorithm.description)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    })
                    HStack(content: {
                        Text("Public Key")
                        Spacer()
                        Text(manager.configuration.publicKeyString)
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    })
                    HStack(content: {
                        Text("Private Key")
                        Spacer()
                        Text(manager.configuration.privateKeyString)
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    })
                }, header: {
                    Text("Key info")
                })
                Section(content: {
                    Button(action: {
                        isPresented.toggle()
                    }, label: {
                        Text("Regenerate")
                    })
                    Link(destination: URL(string: "http://127.0.0.1:8888")!, label: {
                        Text("Install")
                    })
                }, footer: {
                    Text("You should trust the certificate manually after installation in Settings > General > About > Certificate Trust Settings.")
                })
            })
            .alert("Warning!", isPresented: $isPresented, actions: {
                Button(role: .cancel, action: {}, label: {
                    Text("Cancel")
                })
                Button(role: .destructive, action: {
                    manager.generate()
                }, label: {
                    Text("OK")
                })
            }, message: {
                Text("Current certificate will become invalid, do you really want to generate a new certificate?")
            })
            .onAppear(perform: {
                manager.launch()
            })
            .navigationTitle("Certificate View")
        })
    }
}

#Preview {
    CertificateView()
}
