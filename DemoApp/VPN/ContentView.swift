//
//  ContentView.swift
//  VPN
//
//  Created by devonly on 2024/03/24.
//

import SwiftUI
import Mudmouth

struct ContentView: View {
    @State private var isPresented: Bool = false

    var body: some View {
        NavigationView(content: {
            Form(content: {
                Button(action: {
                    isPresented.toggle()
                }, label: {
                    Text("Configuration")
                })
                .sheet(isPresented: $isPresented, content: {
                    CertificateView()
                })
                RefreshButton()
            })
            .navigationTitle("Thunderbolt")
        })
    }
}

#Preview {
    ContentView()
}
