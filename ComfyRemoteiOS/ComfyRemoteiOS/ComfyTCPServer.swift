//
//  ComfyTCPServer.swift
//  ComfyRemoteiOS
//
//  Created by Aryan Rogye on 5/19/25.
//

import Foundation
import Network

class ComfyTCPServer: ObservableObject {
    private var listener: NWListener?
    @Published var status: String = "Idle"
    @Published var isRunning: Bool = false

    func start(port: UInt16 = 50505) {
        do {
            let params = NWParameters.tcp
            listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: port)!)
        } catch {
            status = "❌ Failed to bind to port \(port)"
            return
        }

        listener?.stateUpdateHandler = { [weak self] newState in
            DispatchQueue.main.async {
                switch newState {
                case .ready:
                    self?.status = "✅ Listening on port \(port)"
                    self?.isRunning = true
                case .failed(let err):
                    self?.status = "❌ Failed: \(err.localizedDescription)"
                    self?.isRunning = false
                default:
                    break
                }
            }
        }

        listener?.newConnectionHandler = { newConnection in
            newConnection.start(queue: .main)
            self.receive(on: newConnection)
        }

        listener?.start(queue: .main)
    }

    func stop() {
        listener?.cancel()
        listener = nil
        status = "Stopped"
        isRunning = false
    }

    private func receive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, isComplete, _ in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                print("📥 Received: \(message)")
            }
            if isComplete {
                connection.cancel()
            } else {
                self.receive(on: connection) // keep listening
            }
        }
    }
}
