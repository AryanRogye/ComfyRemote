package com.aryanrogye.comfyremotetv.client;

import android.util.Log;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.util.concurrent.atomic.AtomicBoolean;

public class Client {
    private Socket socket;
    private final AtomicBoolean forceDisconnect = new AtomicBoolean(false);
    private volatile boolean readingStarted = false;

    private void handleMessage(String message) {
        switch (message.trim()) {
            case "UP":
                // Handle UP
                break;
            case "DOWN":
                // Handle DOWN
                break;
            case "LEFT":
                // etc.
                break;
            default:
                Log.e("ComfyClient", "Unknown message: " + message);
                break;
        }
    }
    private void startReadingFromServer() {
        new Thread(() -> {
            try {
                BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
                String message;

                while ((message = in.readLine()) != null) {
                    Log.e("ComfyClient", "📥 Received from server: " + message);
                    handleMessage(message);
                }

                } catch (Exception e) {
                Log.e("ComfyClient", "Error reading from server: " + e.getMessage());
            } finally {
                readingStarted = false;
                if (socket != null && !socket.isClosed()) {
                    try {
                        socket.close();
                        Log.e("ComfyClient", "Socket closed");
                    } catch (IOException e) {
                        Log.e("ComfyClient", "Error closing socket: " + e.getMessage());
                    }
                }
            }
        }).start();
    }

    public void pollServerConnection(String ip, int port, AtomicBoolean serverStarted ,Runnable onStatusChange) {
        new Thread(() -> {

            boolean wasConnected = false;
            while (true) {
                boolean currentlyConnected = checkConnection(ip, port);

                ///  This will show the current state of the connection
                if (currentlyConnected && socket != null && !socket.isClosed() && !readingStarted) {
                    readingStarted = true;
                    // Only start reading once per connection
                    startReadingFromServer();
                }

                // Connection state changed from connected to disconnected
                if (wasConnected && !currentlyConnected) {
                    Log.e("ComfyClient", "❌ Disconnected. Attempting to reconnect...");
                    serverStarted.set(false);
                    if (onStatusChange != null) onStatusChange.run();
                }

                // Not connected, try to connect
                if (!currentlyConnected) {
                    try {
                        socket = new Socket(ip, port);
                        Log.e("ComfyClient", "✅ Connected to server");
                        serverStarted.set(true);
                        currentlyConnected = true; // Update current state
                        if (onStatusChange != null) onStatusChange.run();
                    } catch (Exception ex) {
                        Log.e("ComfyClient", "⚠️ Connection failed: " + ex.getMessage());
                        // Don't notify again to avoid UI spam
                    }
                }

                // Update previous state for next iteration
                wasConnected = currentlyConnected;

                try {
                    Thread.sleep(2000); // Poll every 2 sec
                } catch (InterruptedException e) {
                    Log.e("ComfyClient", "Polling thread interrupted");
                    break;
                }
            }

            }).start();
    }


    private boolean checkConnection(String ip, int port) {
        // Check if socket is null or closed
        if (socket == null || socket.isClosed() || forceDisconnect.get()) {
            return false;
        }

        try {
            // Method 1: Check if socket is connected according to Java
            if (!socket.isConnected()) {
                Log.d("ComfyClient", "Socket reports as not connected");
                closeSocket();
                return false;
            }

            // Method 3: Try to do a quick connection test
            Socket testSocket = null;
            try {
                testSocket = new Socket();
                testSocket.connect(new InetSocketAddress(ip, port), 1000);
                testSocket.close();
            } catch (IOException e) {
                Log.d("ComfyClient", "Test connection failed: " + e.getMessage());
                // If we can't establish a test connection, the server might be down
                closeSocket();
                return false;
            }

            return true;
        } catch (Exception e) {
            Log.e("ComfyClient", "Connection check error: " + e.getMessage());
            closeSocket();
            return false;
        }
    }

    private void closeSocket() {
        if (socket != null) {
            try {
                socket.close();
            } catch (IOException e) {
                Log.e("ComfyClient", "Error closing socket: " + e.getMessage());
            }
            socket = null;
        }
    }

    // Public method that can be called to force a disconnect (if needed)
    public void disconnect() {
        forceDisconnect.set(true);
        closeSocket();
    }
}
