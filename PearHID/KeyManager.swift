//
//  KeyManager.swift
//  PearHID
//
//  Created by Alin Lupascu on 12/20/24.
//

import Foundation
import SwiftUI
import AlinFoundation
import IOKit.hid

struct MainMappingRowView: View {
    @EnvironmentObject var viewModel: MappingsViewModel
    @State private var newMapping = KeyMapping()
    @State private var showingFromPopover = false
    @State private var showingToPopover = false

    var body: some View {
        //        let usedKeys = viewModel.usedKeyStrings

        HStack {
            Button {
                showingFromPopover.toggle()
            } label: {
                Text(newMapping.from?.key ?? "From Key")
                    .frame(width: 150)
            }
            .popover(isPresented: $showingFromPopover) {
                KeySelectionPopover(selectedKey: $newMapping.from,
                                    oppositeKey: newMapping.to,
                                    usedKeys: viewModel.usedKeyStrings,
                                    onDismiss: { showingFromPopover = false })
            }

            Button {
                showingToPopover.toggle()
            } label: {
                Text(newMapping.to?.key ?? "To Key")
                    .frame(width: 150)
            }
            .popover(isPresented: $showingToPopover) {
                KeySelectionPopover(selectedKey: $newMapping.to,
                                    oppositeKey: newMapping.from,
                                    usedKeys: viewModel.usedKeyStrings,
                                    onDismiss: { showingToPopover = false })
            }

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
    @State private var isHovered: Bool = false

    var body: some View {

        HStack {
            HStack {

                Text("\(mapping.from?.key ?? "Unknown")")
                    .frame(maxWidth: .infinity, alignment: .center)

                Image(systemName: "arrow.right").foregroundStyle(.secondary).font(.title2).padding(.horizontal, 5)

                Text("\(mapping.to?.key ?? "Unknown")")
                    .frame(maxWidth: .infinity, alignment: .center)

                Button(action: {
                    viewModel.removeMapping(mapping)
                }) {
                    Image(systemName: "x.circle.fill")
                        .opacity(isHovered ? 1 : 0.5)

                }
                .buttonStyle(.plain)
                .help("Remove this mapping")
                .onHover { hovering in
                    isHovered = hovering
                }

            }
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.secondary.opacity(0.1))
            }

        }

    }
}

// View model holding the array of mappings
class MappingsViewModel: ObservableObject {
    @Published var mappings: [KeyMapping] = []
    @Published var plistLoaded: Bool = false
    var usedKeyStrings: Set<String> {
        Set(mappings.compactMap { $0.from?.key } + mappings.compactMap { $0.to?.key })
    }

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
        let items = mappings.compactMap { mappingToHexString(mapping: $0) }.joined(separator: ",\n")

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
        let items = mappings.compactMap { mappingToHexString(mapping: $0) }.joined(separator: ",\n")

        return """
        {"UserKeyMapping":[
        \(items)
        ]}
        """

    }


    private func mappingToHexString(mapping: KeyMapping) -> String? {
        guard let fromHex = mapping.from?.hex, let toHex = mapping.to?.hex else { return nil }
        return """
                    {
                            "HIDKeyboardModifierMappingSrc": 0x\(String(0x700000000 + UInt64(fromHex), radix: 16).uppercased()),
                            "HIDKeyboardModifierMappingDst": 0x\(String(0x700000000 + UInt64(toHex), radix: 16).uppercased())
                    }
        """
    }
}

extension MappingsViewModel {

    func loadExistingMappings() {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["/usr/bin/hidutil", "property", "--get", "UserKeyMapping"]

        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
        } catch {
            printOS("Failed to execute hidutil command: \(error)")
            return
        }

        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let outputString = String(data: data, encoding: .utf8) else {
            printOS("Failed to read output from hidutil")
            return
        }

        // Remove unwanted characters and format as valid JSON
        let cleanedString = outputString
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "=", with: ":")
            .replacingOccurrences(of: ";", with: ",")
            .replacingOccurrences(of: "HIDKeyboardModifierMappingDst", with: "\"HIDKeyboardModifierMappingDst\"")
            .replacingOccurrences(of: "HIDKeyboardModifierMappingSrc", with: "\"HIDKeyboardModifierMappingSrc\"")
            .replacingOccurrences(of: "(", with: "[")
            .replacingOccurrences(of: ")", with: "]")

        guard let jsonData = cleanedString.data(using: .utf8),
              let mappingsArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            printOS("Failed to parse JSON data or nothing is set")
            return
        }

        let loadedMappings: [KeyMapping] = mappingsArray.compactMap { mapping in
            guard let srcHex = mapping["HIDKeyboardModifierMappingSrc"] as? Int,
                  let dstHex = mapping["HIDKeyboardModifierMappingDst"] as? Int else {
                printOS("Failed to parse hex values from mapping: \(mapping)")
                return nil
            }

            let srcKeyHex = UInt64(srcHex & 0xFF)
            let dstKeyHex = UInt64(dstHex & 0xFF)

            let fromKey = findKeyItem(forHex: srcKeyHex)
            let toKey = findKeyItem(forHex: dstKeyHex)

            guard let fromKey = fromKey, let toKey = toKey else {
                printOS("Could not find matching keys for hex values: src=\(String(format:"0x%X", srcKeyHex)), dst=\(String(format:"0x%X", dstKeyHex))")
                return nil
            }
            return KeyMapping(from: fromKey, to: toKey)
        }

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

            // Step 4. Execute command
            let success = executeFileCommands("\(write); \(chown); \(chmod)")
            if success {
                //                printOS("Successfully setup launchd plist.")
            } else {
                printOS("Failed to setup launchd plist")
            }


        } else {
            // If the file doesn't exist, create it in the correct location
            let tempPath = "/tmp/temp_launch_daemon.plist"
            try data.write(to: URL(fileURLWithPath: tempPath))
            write = "mv \(tempPath) \(plistPath)"
            // Step 3: Run chmod and chown using the Sudo struct
            let chown = "chown root:wheel \(plistPath)"
            let chmod =  "chmod 644 \(plistPath)"

            // Step 5. Execute command
            let success = executeFileCommands("\(write); \(chown); \(chmod)")
            if success {
                self.plistLoaded = true
                //                printOS("Successfully setup launchd plist.")
            } else {
                printOS("Failed to setup launchd plist")
            }

        }

    }

    func removeLaunchDaemon() throws {
        let plistPath = "/Library/LaunchDaemons/com.alienator88.PearHID.KeyRemapping.plist"

        // Step 1: Remove plist file
        let remove = "rm -f \(plistPath)"

        // Step 2: Execute command
        let success = executeFileCommands(remove)
        if success {
            self.plistLoaded = false
        } else {
            printOS("Failed to remove launchd plist")
        }

        self.plistLoaded = false
    }

    func clearHIDKeyMappings() {
        @AppStorage("settings.persistReboot") var persistReboot: Bool = true

        // Command to set UserKeyMapping to an empty array
        let command = "/usr/bin/hidutil property --set '{\"UserKeyMapping\":[]}'"
        let success = executeFileCommands(command)
        if !success {
            printOS("Clear Error: Failed to clear HIDKeyboardModifiers for this session")
        }
        self.loadExistingMappings()

        if persistReboot {
            do {
                try removeLaunchDaemon()
            } catch {
                printOS("Clear Plist Error: \(error.localizedDescription)")
            }
        }

    }

    func setHIDKeyMappings() {
        @AppStorage("settings.persistReboot") var persistReboot: Bool = true

        // Generate HIDKeyboardModifiers
        let mappingsJSON = generateHIDmappings()

        // Command to set UserKeyMapping with generated mappings
        //        let compactJSON = mappingsJSON
        //            .components(separatedBy: .whitespacesAndNewlines)
        //            .joined()
        //            .replacingOccurrences(of: "\"", with: "\\\"")
        //
        //        let command = "/usr/bin/hidutil property --set \"\(mappingsJSON)\""
        //        print(command)
        let success = runHIDUtil(with: mappingsJSON)
        if !success {
            printOS("Set Error: Failed to set HIDKeyboardModifiers for this session")
        }

        //        applyKeyMappingsFromJSON(mappingsJSON)

        if persistReboot {
            do {
                try setupLaunchDaemon(plistContent: generatePlist())
            } catch {
                printOS("Set Plist Error: \(error.localizedDescription)")
            }
        }
    }
}

func runHIDUtil(with json: String) -> Bool {
    let process = Process()
    process.launchPath = "/usr/bin/hidutil"
    process.arguments = ["property", "--set", "\(json)"]
    let cmdArgs = process.arguments?.joined(separator: " ") ?? ""
    printOS("COMMAND: \(process.launchPath ?? "") \(cmdArgs)")

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
        try process.run()
    } catch {
        printOS("Failed to run hidutil: \(error)")
        return false
    }

    process.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        printOS("hidutil output: \(output)")
    }

    return process.terminationStatus == 0
}

func executeFileCommands(_ commands: String) -> Bool {
    var status = false

    if HelperToolManager.shared.isHelperToolInstalled {
        let semaphore = DispatchSemaphore(value: 0)
        var success = false
        var output = ""

        Task {
            let result = await HelperToolManager.shared.runCommand(commands)
            success = result.0
            output = result.1
            semaphore.signal()
        }
        semaphore.wait()

        status = success
        if !success {
            printOS("Helper Error: \(output)")
        }
    } else {
        let result = performPrivilegedCommands(commands: commands)
        status = result.0
        if !status {
            printOS("Auth Services Error: \(result.1)")
        }

    }

    return status
}

func applyKeyMappingsFromJSON(_ json: String) {
    guard let data = json.data(using: .utf8),
          let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
        printOS("Invalid JSON for UserKeyMapping: \(json)")
        return
    }

    let systemClient = IOHIDEventSystemClientCreateSimpleClient(kCFAllocatorDefault)

    guard let services = IOHIDEventSystemClientCopyServices(systemClient) as? [IOHIDServiceClient] else {
        printOS("Failed to get HID services")
        return
    }

    for service in services {
        if IOHIDServiceClientConformsTo(service, UInt32(kHIDPage_GenericDesktop), UInt32(kHIDUsage_GD_Keyboard)) != 0 {
            let success = IOHIDServiceClientSetProperty(service,
                                                        kIOHIDUserKeyUsageMapKey as CFString,
                                                        array as CFArray)
            if !success {
                printOS("Failed to apply mapping to service")
            }
        }
    }
}

struct KeySelectionPopover: View {
    @Binding var selectedKey: KeyItem?
    let oppositeKey: KeyItem?
    let usedKeys: Set<String>
    let onDismiss: () -> Void
    @State private var selectedGroup: KeyGroup?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let group = selectedGroup {
                Text("← Back")
                    .foregroundStyle(.secondary)
                    .clipShape(Rectangle())
                    .padding()
                    .frame(width: .infinity)
                    .onTapGesture {
                        selectedGroup = nil
                    }
                Divider()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(group.keys) { key in
                            Button(action: {
                                selectedKey = key
                                onDismiss()
                                selectedGroup = nil
                            }) {
                                Text(key.key)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal)
                            }
                            .disabled(oppositeKey?.key == key.key || usedKeys.contains(key.key))
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                }
            } else {
                Text("Select a key").foregroundStyle(.secondary)
                    .padding()
                Divider()
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(allKeys) { group in
                            Button(action: {
                                selectedGroup = group
                            }) {
                                Text(group.group)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal)
                            }
                            .buttonStyle(.plain)
                            Divider()
                        }
                    }
                }
            }
        }
        .frame(width: 200)
    }
}


