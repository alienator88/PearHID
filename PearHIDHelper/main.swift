//
//  main.swift
//  PearHIDHelper
//
//  Created by Alin Lupascu on 4/4/25.
//

import Foundation

@objc(HelperToolProtocol)
public protocol HelperToolProtocol {
    func runCommand(command: String, withReply reply: @escaping (Bool, String) -> Void)
}

// XPC Communication setup
class HelperToolDelegate: NSObject, NSXPCListenerDelegate, HelperToolProtocol {
    private var activeConnections = Set<NSXPCConnection>()

    override init() {
        super.init()
    }

    // Accept new XPC connections by setting up the exported interface and object.
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: HelperToolProtocol.self)
        newConnection.exportedObject = self
        newConnection.invalidationHandler = { [weak self] in
            self?.activeConnections.remove(newConnection)
            if self?.activeConnections.isEmpty == true {
                exit(0) // Exit when no active connections remain
            }
        }
        activeConnections.insert(newConnection)
        newConnection.resume()
        return true
    }

    // Execute the shell command and reply with output.
    func runCommand(command: String, withReply reply: @escaping (Bool, String) -> Void) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            reply(false, "Failed to run command: \(error.localizedDescription)")
            return
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let success = (process.terminationStatus == 0) // Check if process exited successfully
        reply(success, output.isEmpty ? "No output" : output)
    }
}

// Set up and start the XPC listener.
let delegate = HelperToolDelegate()
let listener = NSXPCListener(machServiceName: "com.alienator88.PearHID.Helper")
listener.delegate = delegate
listener.resume()
RunLoop.main.run()
