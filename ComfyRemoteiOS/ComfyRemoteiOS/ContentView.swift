//
//  ContentView.swift
//  ComfyRemoteiOS
//
//  Created by Aryan Rogye on 5/19/25.
//

import SwiftUI
import Network

struct ContentView: View {
    @StateObject private var server = ComfyTCPServer()

    var body: some View {
        VStack(spacing: 20) {
            Text("📡 ComfyRemote iOS Server")
                .font(.title)

            Text("Status: \(server.status)")
                .foregroundStyle(.secondary)

            Button(server.isRunning ? "Stop Server" : "Start Server") {
                server.isRunning ? server.stop() : server.start()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
