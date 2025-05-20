//
//  Untitled.swift
//  ComfyRemoteiOS
//
//  Created by Aryan Rogye on 5/19/25.
//

import SwiftUI

struct ServerControls: View {
    @StateObject private var server : ComfyTCPServer = .shared
    var body: some View {
        HStack {
            VStack {
                Text("Status: \(server.status)")
                    .foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity)
            Spacer()
            VStack {
                Button(action: {
                    server.isRunning ? server.stop() : server.start()
                }) {
                    Text(server.isRunning ? "Stop Server" : "Start Server")
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(server.isRunning ? .red : .green, lineWidth: 2)
                        )
                        .background(server.isRunning ? .red.opacity(0.2) : .green.opacity(0.2))
                        .foregroundColor(server.isRunning ? .red : .green)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
