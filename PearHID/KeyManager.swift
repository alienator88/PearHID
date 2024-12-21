//
//  KeyManager.swift
//  PearHID
//
//  Created by Alin Lupascu on 12/20/24.
//

import Foundation
import SwiftUI
import AlinFoundation

struct MainMappingRowView: View {
    @EnvironmentObject var viewModel: MappingsViewModel
    @State private var newMapping = KeyMapping()

    var body: some View {
        let usedKeys: Set<String> = Set(viewModel.mappings.compactMap { $0.from?.key } + viewModel.mappings.compactMap { $0.to?.key })

        HStack {
            Menu(newMapping.from?.key ?? "From Key") {
                ForEach(allKeys) { group in
                    Menu(group.group) {
                        ForEach(group.keys) { key in
                            Button(key.key) {
                                newMapping.from = key
                            }
                            .disabled(newMapping.to?.key == key.key || usedKeys.contains(key.key))
                        }
                    }
                }
            }
            .frame(width: 150)

            Image(systemName: "arrow.right").foregroundStyle(.secondary).font(.title2).padding(.horizontal, 5)

            Menu(newMapping.to?.key ?? "To Key") {
                ForEach(allKeys) { group in
                    Menu(group.group) {
                        ForEach(group.keys) { key in
                            Button(key.key) {
                                newMapping.to = key
                            }
                            .disabled(newMapping.from?.key == key.key || usedKeys.contains(key.key))
                        }
                    }
                }
            }
            .frame(width: 150)

            Button {
                if let _ = newMapping.from, let _ = newMapping.to {
                    viewModel.mappings.append(newMapping)
                    newMapping = KeyMapping()
                }
            } label: {
                Image(systemName: "plus")
            }
            .disabled(newMapping.from == nil || newMapping.to == nil)

        }
    }
}



struct MappingRowListItem: View {
    @EnvironmentObject var viewModel: MappingsViewModel
    let mapping: KeyMapping

    var body: some View {
        HStack {
            Text("\(mapping.from?.key ?? "Unknown")")
                .frame(maxWidth: .infinity, alignment: .leading) // Left-aligned with flexible width
            Spacer()
            Image(systemName: "arrow.right").foregroundStyle(.secondary).font(.title2).padding(.horizontal, 5)
            Spacer()
            Text("\(mapping.to?.key ?? "Unknown")")
                .frame(maxWidth: .infinity, alignment: .leading) // Left-aligned with flexible width
            Spacer()
            Button(action: {
                viewModel.removeMapping(mapping)
            }) {
                Image(systemName: "trash")
                    .padding(5)
                    .padding(.horizontal, 2)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .shadow(radius: 2)
            }
            .buttonStyle(.plain)
            .help("Remove this mapping")

        }
    }
}




// View model holding the array of mappings
class MappingsViewModel: ObservableObject {
    @Published var mappings: [KeyMapping] = []
    @Published var plistLoaded: Bool = false

    init() {
        loadExistingMappings()
    }

    func addMapping() {
        mappings.append(KeyMapping())
    }

    func removeMapping(_ mapping: KeyMapping) {
        mappings.removeAll { $0.id == mapping.id }
    }

    func removeAllMappings() {
        mappings.removeAll()
    }

    // Generate plist string from current mappings
    func generatePlist() -> String {
        let items = mappings.compactMap { mapping -> String? in
            guard let fromHex = mapping.from?.hex, let toHex = mapping.to?.hex else { return nil }
            return """
                        {
                                "HIDKeyboardModifierMappingSrc": 0x7000000\(String(fromHex, radix:16).uppercased()),
                                "HIDKeyboardModifierMappingDst": 0x7000000\(String(toHex, radix:16).uppercased())
                        }
            """
        }.joined(separator: ",\n")

        return """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" \
        "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>com.alienator88.PearHID.KeyRemapping</string>
                <key>ProgramArguments</key>
                <array>
                    <string>/usr/bin/hidutil</string>
                    <string>property</string>
                    <string>--set</string>
                    <string>{"UserKeyMapping":[
            \(items)
                    ]}</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
            </dict>
        </plist>
        """
    }

    func generateHIDmappings() -> String {
        let items = mappings.compactMap { mapping -> String? in
            guard let fromHex = mapping.from?.hex, let toHex = mapping.to?.hex else { return nil }
            return """
                        {
                                "HIDKeyboardModifierMappingSrc": 0x7000000\(String(fromHex, radix:16).uppercased()),
                                "HIDKeyboardModifierMappingDst": 0x7000000\(String(toHex, radix:16).uppercased())
                        }
            """
        }.joined(separator: ",\n")

        return """
        {"UserKeyMapping":[
        \(items)
        ]}
        """

    }
}

extension MappingsViewModel {

    func loadExistingMappings() {
        let launchDaemonsPath = "/Library/LaunchDaemons/com.alienator88.PearHID.KeyRemapping.plist"

        guard FileManager.default.fileExists(atPath: launchDaemonsPath) else {
            print("File does not exist at path: \(launchDaemonsPath)")
            return
        }

        guard let data = try? Data(contentsOf: URL(fileURLWithPath: launchDaemonsPath)),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let arguments = plist["ProgramArguments"] as? [String],
              let jsonString = arguments.last else {
            print("Failed to read plist or get mapping string")
            return
        }


        // Convert hex values to decimal strings
        let hexPattern = "0x[0-9A-Fa-f]+"
        let regex = try? NSRegularExpression(pattern: hexPattern, options: [])
        var processedString = jsonString

        if let regex = regex {
            // Find all matches and convert them from last to first (to avoid changing string indices)
            let matches = regex.matches(in: jsonString, options: [], range: NSRange(jsonString.startIndex..., in: jsonString))
            for match in matches.reversed() {
                if let range = Range(match.range, in: jsonString) {
                    let hexString = String(jsonString[range])
                    // Convert hex to decimal
                    if let hexNumber = Int(hexString.replacingOccurrences(of: "0x", with: ""), radix: 16) {
                        processedString = processedString.replacingOccurrences(of: hexString, with: "\(hexNumber)")
                    }
                }
            }
        }

        // Parse the JSON string containing the mappings
        guard let jsonData = processedString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: [[String: Any]]] else {
            print("Failed to parse JSON data")
            if let jsonData = processedString.data(using: .utf8) {
                do {
                    let _ = try JSONSerialization.jsonObject(with: jsonData)
                } catch {
                    print("JSON parsing error: \(error)")
                }
            }
            return
        }

        guard let mappingsArray = json["UserKeyMapping"] else {
            print("Failed to get UserKeyMapping array")
            return
        }

        // Convert the parsed mappings back into KeyMapping objects
        let loadedMappings: [KeyMapping] = mappingsArray.compactMap { mapping in
            guard let srcHex = mapping["HIDKeyboardModifierMappingSrc"] as? Int,
                  let dstHex = mapping["HIDKeyboardModifierMappingDst"] as? Int else {
                print("Failed to parse hex values from mapping: \(mapping)")
                return nil
            }

            // Extract just the last two digits from the hex value (after 0x70000000)
            let srcKeyHex = UInt64(srcHex & 0xFF)  // Keep only the last byte
            let dstKeyHex = UInt64(dstHex & 0xFF)  // Keep only the last byte

//            print("Looking for keys with hex values: src=\(String(format:"0x%X", srcKeyHex)), dst=\(String(format:"0x%X", dstKeyHex))")

            // Find matching KeyItems from our allKeys array
            let fromKey = findKeyItem(forHex: srcKeyHex)
            let toKey = findKeyItem(forHex: dstKeyHex)

            guard let fromKey = fromKey, let toKey = toKey else {
                print("Could not find matching keys for hex values: src=\(String(format:"0x%X", srcKeyHex)), dst=\(String(format:"0x%X", dstKeyHex))")
                // Debug print all key hex values
//                for group in allKeys {
//                    for key in group.keys {
//                        print("Available key: \(key.key) = \(String(format:"0x%X", key.hex))")
//                    }
//                }
                return nil
            }
            return KeyMapping(from: fromKey, to: toKey)
        }

        // Update the viewModel's mappings on the main thread
        DispatchQueue.main.async {
            self.mappings = loadedMappings
            self.plistLoaded = true
        }
    }

    private func findKeyItem(forHex hex: UInt64) -> KeyItem? {
        for group in allKeys {
            if let key = group.keys.first(where: { $0.hex == hex }) {
                return key
            }
        }
        return nil
    }

    func setupLaunchDaemon(plistContent: String) throws {
        let plistPath = "/Library/LaunchDaemons/com.alienator88.PearHID.KeyRemapping.plist"
        var write = ""

        // Step 1: Validate the plist content
        guard let data = plistContent.data(using: .utf8) else {
            throw NSError(domain: "InvalidPlist", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid plist string encoding."])
        }
        do {
            _ = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        } catch {
            throw NSError(domain: "InvalidPlist", code: 2, userInfo: [NSLocalizedDescriptionKey: "Plist content is invalid: \(error.localizedDescription)"])
        }
        // Step 2: Check if file already exists
        if FileManager.default.fileExists(atPath: plistPath) {
            // Overwrite the existing file with sudo
            let tempPath = "/tmp/temp_launch_daemon.plist"
            try data.write(to: URL(fileURLWithPath: tempPath))
            write = "cp \(tempPath) \(plistPath)"
            // Step 3: Run chmod and chown using the Sudo struct
            let chown = "chown root:wheel \(plistPath)"
            let chmod =  "chmod 644 \(plistPath)"

            // Step 4: Start the daemon
//            let bootstrap = "launchctl bootstrap system \(plistPath)"

            // Step 5. Execute command
            _ = Sudo.run(cmd: "\(write); \(chown); \(chmod)")
            self.setHIDKeyMappings()
//            try FileManager.default.removeItem(atPath: tempPath)
        } else {
            // If the file doesn't exist, create it in the correct location
            let tempPath = "/tmp/temp_launch_daemon.plist"
            try data.write(to: URL(fileURLWithPath: tempPath))
            write = "mv \(tempPath) \(plistPath)"
            // Step 3: Run chmod and chown using the Sudo struct
            let chown = "chown root:wheel \(plistPath)"
            let chmod =  "chmod 644 \(plistPath)"

            // Step 4: Start the daemon
//            let bootstrap = "launchctl bootstrap system \(plistPath)"

            // Step 5. Execute command
            _ = Sudo.run(cmd: "\(write); \(chown); \(chmod)")
            self.setHIDKeyMappings()
            self.plistLoaded = true
        }

    }

    func removeLaunchDaemon() throws {
        let plistPath = "/Library/LaunchDaemons/com.alienator88.PearHID.KeyRemapping.plist"

        // Step 1: Stop the daemon
//        let bootout = "launchctl bootout system \(plistPath)"

        // Step 2: Remove plist file
        let remove = "rm -f \(plistPath)"

        // Step 3: Execute command
        _ = Sudo.run(cmd: "\(remove)")

        self.clearHIDKeyMappings()
        self.plistLoaded = false
    }

    func clearHIDKeyMappings() {
        // Command to set UserKeyMapping to an empty array
        let command = "hidutil property --set '{\"UserKeyMapping\":[]}'"
        executeCommand(command: command)
    }

    func setHIDKeyMappings() {
        // Generate HIDKeyboardModifiers wrapped correctly
        let mappingsJSON = generateHIDmappings()
//        mappingsJSON = mappingsJSON.replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)

        // Command to set UserKeyMapping with generated mappings
        let command = "hidutil property --set '\(mappingsJSON)'"
        executeCommand(command: command)
    }

    private func executeCommand(command: String) {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", command]

        // Set the environment to inherit the current process's environment
        task.environment = ProcessInfo.processInfo.environment

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe

        task.launch()
        task.waitUntilExit()

//        let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
//        if let output = String(data: outputData, encoding: .utf8) {
//            printOS("Command Output:\n\(output)")
//        }
    }
}

