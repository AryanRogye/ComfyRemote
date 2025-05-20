//
//  ContentView.swift
//  ComfyRemoteiOS
//
//  Created by Aryan Rogye on 5/19/25.
//

import SwiftUI
import Network

struct ContentView: View {
    @StateObject private var server : ComfyTCPServer = .shared

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea(.all)
            VStack(spacing: 20) {
                Text("📡 ComfyRemote iOS Server")
                    .font(.title)
                    .foregroundStyle(.black)
                ServerControls()
                DPadLayout()
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
