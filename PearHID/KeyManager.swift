//
//  KeyManager.swift
//  PearHID
//
//  Created by Alin Lupascu on 12/20/24.
//

import AlinFoundation
import Foundation
import IOKit.hid
import SwiftUI

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
                KeySelectionPopover(
                    selectedKey: $newMapping.from,
                    oppositeKey: newMapping.to,
                    usedKeys: viewModel.usedFromKeys,
                    onDismiss: { showingFromPopover = false })
            }

            Button {
                showingToPopover.toggle()
            } label: {
                Text(newMapping.to?.key ?? "To Key")
                    .frame(width: 150)
            }
            .popover(isPresented: $showingToPopover) {
                KeySelectionPopover(
                    selectedKey: $newMapping.to,
                    oppositeKey: newMapping.from,
                    usedKeys: viewModel.usedToKeys,
                    onDismiss: { showingToPopover = false })
            }

            Button {
                if newMapping.from != nil, newMapping.to != nil {
                    viewModel.mappings.append(newMapping)
                    newMapping = KeyMapping()
                }
            } label: {
                Image(systemName: "plus")
            }
            .opacity((newMapping.from == nil || newMapping.to == nil) ? 0.5 : 1)
            .disabled(newMapping.from == nil || newMapping.to == nil)
            .help("Select From and To keys to add mapping")

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

struct MappingRowListItem: View {
    @EnvironmentObject var viewModel: MappingsViewModel
    let mapping: KeyMapping
    @State private var isHovered: Bool = false

    var body: some View {

        HStack {
            HStack {

                Text("\(mapping.from?.key ?? "Unknown")")
                    .frame(maxWidth: .infinity, alignment: .center)

                Image(systemName: "arrow.right").foregroundStyle(.secondary).font(.title2).padding(
                    .horizontal, 5)

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
    var usedFromKeys: Set<String> {
        Set(mappings.compactMap { $0.from?.key })
    }
    var usedToKeys: Set<String> {
        Set(mappings.compactMap { $0.to?.key })
    }

    init() {
        loadExistingMappingsFromAPI()
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
                    <string>PearHID.KeyMapping</string>
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

    private func mappingToHexString(mapping: KeyMapping) -> String? {
        guard let fromHex = mapping.from?.hex, let toHex = mapping.to?.hex else { return nil }
        return """
                        {
                                "HIDKeyboardModifierMappingSrc": 0x\(String(0x7_0000_0000 + UInt64(fromHex), radix: 16).uppercased()),
                                "HIDKeyboardModifierMappingDst": 0x\(String(0x7_0000_0000 + UInt64(toHex), radix: 16).uppercased())
                        }
            """
    }
}

extension MappingsViewModel {

    func loadExistingMappingsFromAPI() {
        let systemClient = IOHIDEventSystemClientCreateSimpleClient(kCFAllocatorDefault)

        guard
            let services = IOHIDEventSystemClientCopyServices(systemClient) as? [IOHIDServiceClient]
        else {
            printOS("Failed to get HID services")
            return
        }

        for service in services {
            if IOHIDServiceClientConformsTo(
                service, UInt32(kHIDPage_GenericDesktop), UInt32(kHIDUsage_GD_Keyboard)) != 0,
                let props = IOHIDServiceClientCopyProperty(
                    service, kIOHIDUserKeyUsageMapKey as CFString) as? [[String: UInt64]]
            {

                let loadedMappings: [KeyMapping] = props.compactMap { mapping in
                    let srcHex = mapping["HIDKeyboardModifierMappingSrc"] ?? 0
                    let dstHex = mapping["HIDKeyboardModifierMappingDst"] ?? 0

                    let srcKeyHex = UInt64(srcHex & 0xFF)
                    let dstKeyHex = UInt64(dstHex & 0xFF)

                    let fromKey = findKeyItem(forHex: srcKeyHex)
                    let toKey = findKeyItem(forHex: dstKeyHex)

                    guard let fromKey = fromKey, let toKey = toKey else {
                        printOS(
                            "Could not find matching keys for src=\(String(format:"0x%X", srcKeyHex)), dst=\(String(format:"0x%X", dstKeyHex))"
                        )
                        return nil
                    }

                    return KeyMapping(from: fromKey, to: toKey)
                }

                DispatchQueue.main.async {
                    self.mappings = loadedMappings
                    self.plistLoaded = true
                }
                return
            }
        }

        printOS("No UserKeyMapping found via API")
    }

    private func findKeyItem(forHex hex: UInt64) -> KeyItem? {
        for group in allKeys {
            if let key = group.keys.first(where: { $0.hex == hex }) {
                return key
            }
        }
        return nil
    }

    func setupLaunchDaemon(plistContent: String? = nil, install: Bool) throws {
        let plistPath = "/Library/LaunchDaemons/PearHID.KeyMapping.plist"

        if install {
            // Step 1: Validate the plist content
            guard let plistContent, let data = plistContent.data(using: .utf8) else {
                printOS("Invalid plist string encoding.")
                return
            }
            do {
                _ = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
            } catch {
                printOS("Plist content is invalid: \(error.localizedDescription)")
                return
            }
            // Step 2: Check if file already exists
            if FileManager.default.fileExists(atPath: plistPath) {
                // Overwrite the existing file with sudo
                let tempPath = "/tmp/temp_launch_daemon.plist"
                try data.write(to: URL(fileURLWithPath: tempPath))

                let copy = "cp \(tempPath) \(plistPath)"
                let chown = "chown root:wheel \(plistPath)"
                let chmod = "chmod 644 \(plistPath)"

                let success = executeFileCommands("\(copy); \(chown); \(chmod)")
                if success {
                } else {
                    printOS("Failed to setup launchd plist")
                }

            } else {
                // If the file doesn't exist, create it in the correct location
                let tempPath = "/tmp/temp_launch_daemon.plist"
                try data.write(to: URL(fileURLWithPath: tempPath))

                let move = "mv \(tempPath) \(plistPath)"
                let chown = "chown root:wheel \(plistPath)"
                let chmod = "chmod 644 \(plistPath)"

                let success = executeFileCommands("\(move); \(chown); \(chmod)")
                if success {
                    self.plistLoaded = true
                } else {
                    printOS("Failed to setup launchd plist")
                }

            }
        } else {
            // Step 1: Remove plist file
            let success = executeFileCommands("rm -f \(plistPath)")
            if success {
                self.plistLoaded = false
            } else {
                printOS("Failed to remove launchd plist")
            }

            self.plistLoaded = false
        }

    }

    func applyKeyMappingsAPI(mappings: [KeyMapping]) {
        @AppStorage("settings.persistReboot") var persistReboot: Bool = true

        let array: [[String: UInt64]] = mappings.compactMap {
            guard let from = $0.from?.hex, let to = $0.to?.hex else { return nil }
            return [
                "HIDKeyboardModifierMappingSrc": 0x7_0000_0000 + UInt64(from),
                "HIDKeyboardModifierMappingDst": 0x7_0000_0000 + UInt64(to),
            ]
        }

        let systemClient = IOHIDEventSystemClientCreateSimpleClient(kCFAllocatorDefault)

        guard
            let services = IOHIDEventSystemClientCopyServices(systemClient) as? [IOHIDServiceClient]
        else {
            printOS("Failed to get HID services")
            return
        }

        for service in services {
            if IOHIDServiceClientConformsTo(
                service, UInt32(kHIDPage_GenericDesktop), UInt32(kHIDUsage_GD_Keyboard)) != 0
            {
                let success = IOHIDServiceClientSetProperty(
                    service,
                    kIOHIDUserKeyUsageMapKey as CFString,
                    array as CFArray)
                if !success {
                    printOS("Failed to apply mapping to service")
                }
            }
        }

        if persistReboot {
            do {
                if mappings.isEmpty {
                    try setupLaunchDaemon(install: false)
                } else {
                    try setupLaunchDaemon(plistContent: generatePlist(), install: true)
                }
            } catch {
                printOS("Set Plist Error: \(error.localizedDescription)")
            }
        }

    }

    func clearHIDKeyMappings(show: Binding<Bool>) {
        if isAccessibilityGranted() {
            mappings = []
            applyKeyMappingsAPI(mappings: mappings)
            withAnimation { show.wrappedValue = true }
        } else {
            checkAndRequestAccessibilityPermission()
        }

    }

    func setHIDKeyMappings(show: Binding<Bool>) {
        if isAccessibilityGranted() {
            applyKeyMappingsAPI(mappings: mappings)
            withAnimation { show.wrappedValue = true }
        } else {
            checkAndRequestAccessibilityPermission()
        }
    }
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
