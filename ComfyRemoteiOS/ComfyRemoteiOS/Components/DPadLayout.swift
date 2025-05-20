//
//  DPadLayout.swift
//  ComfyRemoteiOS
//
//  Created by Aryan Rogye on 5/19/25.
//
import SwiftUI

struct DPadLayout: View {
    @StateObject private var server: ComfyTCPServer = .shared
    var body: some View {
        if server.isRunning {
            VStack(spacing: 20) {
                // UP
                Button(action: { server.up() }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 32, weight: .bold))
                        .frame(width: 60, height: 60)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
                
                // LEFT - SELECT - RIGHT
                HStack(spacing: 40) {
                    Button(action: { server.left() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 32, weight: .bold))
                            .frame(width: 60, height: 60)
                    }
                    .buttonStyle(.borderedProminent)
                    .clipShape(Circle())
                    
                    Button(action: { server.select() }) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 28))
                            .frame(width: 60, height: 60)
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                    .clipShape(Circle())
                    
                    Button(action: { server.right() }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 32, weight: .bold))
                            .frame(width: 60, height: 60)
                    }
                    .buttonStyle(.borderedProminent)
                    .clipShape(Circle())
                }
                
                // DOWN
                Button(action: { server.down() }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 32, weight: .bold))
                        .frame(width: 60, height: 60)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
            }
        }
    }
}
