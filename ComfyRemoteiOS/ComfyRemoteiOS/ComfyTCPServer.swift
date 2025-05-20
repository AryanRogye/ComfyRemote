//
//  ComfyTCPServer.swift
//  ComfyRemoteiOS
//
//  Created by Aryan Rogye on 5/19/25.
//

import Foundation
import Network
import SwiftUI

class ComfyTCPServer: ObservableObject {
    
    static let shared = ComfyTCPServer()
    
    // Mark:- Public state
    @Published var status       = "Idle"
    @Published var isRunning    = false
    
    // MARK:– Internals
    private var listener: NWListener?
    private var connections: [NWConnection] = []          // <- holds every connection
    private var primaryConnection: NWConnection?          // <- the one you send to

    // MARK:– Start / Stop
    func start(port: UInt16 = 50505) {
        do {
            let params = NWParameters.tcp
            listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: port)!)
        } catch {
            status = "❌ Failed to bind to port \(port)"
            return
        }
        
        /// Start Listening for Connections
        listener?.newConnectionHandler = { [weak self] newConn in
            guard let self = self else { return }
            self.configure(newConn)
        }

        listener?.stateUpdateHandler = { [weak self] newState in
            DispatchQueue.main.async {
                switch newState {
                case .ready:
                    self?.status = "✅ Listening on port \(port)"
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self?.isRunning = true
                    }
                case .waiting: self?.status = "Waiting for network..."
                case .failed(let err):
                    self?.status = "❌ Failed: \(err.localizedDescription)"
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self?.isRunning = false
                    }
                default: break
                }
            }
        }

        /// Starts TCP Server Itself
        listener?.start(queue: .main)
    }

    func stop() {
        connections.forEach { $0.cancel() }
        listener?.cancel()
        connections.removeAll()
        listener = nil
        status = "Stopped"
        withAnimation(.easeInOut(duration: 0.3)) {
            isRunning = false
        }
    }
    
    /// Mark:- Send API
    private func send(_ message: String) {
        guard let connection = primaryConnection else {
            print("❌ No active connection to send data.")
            return
        }
        
        let data = (message + "\n").data(using: .utf8)!
        connection.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("❌ Send error: \(error.localizedDescription)")
            } else {
                print("📤 Sent: \(message)")
            }
        })
    }
    
    public func up()     { guard isRunning else { return }; send("UP") }
    public func down()   { guard isRunning else { return }; send("DOWN") }
    public func left()   { guard isRunning else { return }; send("LEFT") }
    public func right()  { guard isRunning else { return }; send("RIGHT") }
    public func select() { guard isRunning else { return }; send("SELECT") }

    
    private func receive(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, isComplete, error in
            if let error = error {
                print("❌ Receive error: \(error.localizedDescription)")
                self.remove(connection)
                return
            }
            if isComplete {
                self.remove(connection)
                return
            }
            self.receive(on: connection) // keep listening
        }
    }
    
    private func configure(_ conn: NWConnection) {
        connections.append(conn)
        // Promote first connection that lasts > 0.5 s to primary
        if primaryConnection == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self, weak conn] in
                guard let self = self, let conn = conn, conn.state == .ready else { return }
                self.primaryConnection = conn
                print("🌟 Promoted primary connection:", conn.endpoint)
            }
        }
        
        conn.stateUpdateHandler = { [weak self] state in
            if case .failed = state { self?.remove(conn) }
            if case .cancelled = state { self?.remove(conn) }
        }
        receive(on: conn)
        conn.start(queue: .main)
    }
    
    private func remove(_ conn: NWConnection) {
        connections.removeAll { $0 === conn }
        if primaryConnection === conn { primaryConnection = nil }
        print("🗑️  Connection removed:", conn.endpoint)
    }
}
