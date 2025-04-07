//
//  SettingsView.swift
//  PearHID
//
//  Created by Alin Lupascu on 4/4/25.
//

import SwiftUI
import Foundation
import AlinFoundation

struct SettingsView: View {
    @ObservedObject private var helperToolManager = HelperToolManager.shared
    @EnvironmentObject var updater: Updater
    @AppStorage("settings.persistReboot") private var persistReboot: Bool = true
    @State private var commandOutput: String = "Command output will display here"
    @State private var commandToRun: String = "whoami"
    @State private var commandToRunManual: String = ""
    @State private var showTestingUI: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                GroupBox(label:
                            HStack {
                    Text("Helper Tool").font(.title2)
                    Spacer()
                    Button(action: {
                        helperToolManager.openSMSettings()
                    }) {
                        Label("Login Items", systemImage: "gear")
                            .padding(4)
                    }
                    .buttonStyle(.borderedProminent)
                    .contextMenu {
                        Button("Kickstart Service") {
                            let result = performPrivilegedCommands(commands: "launchctl kickstart -k system/com.alienator88.PearHID.Helper")
                            if !result.0 {
                                printOS("Helper Kickstart Error: \(result.1)")
                            }
                        }
                    }
                }
                    .padding(.bottom, 5)
                ) {
                    VStack {
                        HStack(spacing: 0) {
                            Image(systemName: "lock")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding(.trailing, 5)
                                .foregroundStyle(.primary)
                                .onTapGesture {
                                    showTestingUI.toggle()
                                }
                            Text("Perform privileged operations seamlessly")
                                .font(.callout)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Toggle(isOn: Binding(
                                get: { helperToolManager.isHelperToolInstalled },
                                set: { newValue in
                                    Task {
                                        if newValue {
                                            await helperToolManager.manageHelperTool(action: .install)
                                        } else {
                                            await helperToolManager.manageHelperTool(action: .uninstall)
                                        }
                                    }
                                }
                            ), label: {
                            })
                            .toggleStyle(.switch)
                            .frame(alignment: .trailing)
                        }

                        Divider()
                            .padding(.vertical, 5)

                        HStack {
                            Text(helperToolManager.message)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                    .padding(5)
                }


                if showTestingUI {
                    GroupBox(label: Text("Permission Testing").font(.title2).padding(.bottom, 5)) {
                        VStack {

                            Picker("Example privileged commands", selection: $commandToRun) {
                                Text("whoami").tag("whoami")
                                Text("systemsetup -getsleep").tag("systemsetup -getsleep")
                                Text("systemsetup -getcomputername").tag("systemsetup -getcomputername")
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: commandToRun) { newValue in
                                if helperToolManager.isHelperToolInstalled {
                                    Task {
                                        let (success, output) = await helperToolManager.runCommand(commandToRun)
                                        if success {
                                            commandOutput = output
                                        } else {
                                            commandOutput = "Error: \(output)"
                                        }
                                    }
                                }
                            }
                            .onAppear{
                                if helperToolManager.isHelperToolInstalled {
                                    Task {
                                        let (success, output) = await helperToolManager.runCommand(commandToRun)
                                        if success {
                                            commandOutput = output
                                        } else {
                                            commandOutput = "Error: \(output)"
                                        }
                                    }
                                }
                            }

                            TextField("Enter manual command here, Enter to run", text: $commandToRunManual)
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 8).strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1))
                                .textFieldStyle(.plain)
                                .onSubmit {
                                    Task {
                                        let (success, output) = await helperToolManager.runCommand(commandToRunManual)
                                        if success {
                                            commandOutput = output
                                        } else {
                                            commandOutput = "Error: \(output)"
                                        }
                                    }
                                }

                            ScrollView {
                                Text(commandOutput)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    .padding()
                            }
                            .frame(height: 185)
                            .frame(maxWidth: .infinity)
                            .background(.tertiary.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(5)
                        .disabled(!helperToolManager.isHelperToolInstalled)
                        .opacity(helperToolManager.isHelperToolInstalled ? 1 : 0.5)
                    }
                }

                GroupBox(label: Text("Persistence").font(.title2).padding(.bottom, 5), content: {
                    HStack(spacing: 0) {
                        Image(systemName: "autostartstop")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 5)
                            .foregroundStyle(.primary)
                        Text("Keep changes on reboot via launch daemon")
                            .font(.callout)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Toggle("", isOn: $persistReboot)
                            .toggleStyle(.switch)
                    }
                    .padding(5)
                    .help("If this is enabled, a LaunchDaemon will be installed so the mappings survive reboots. Otherwise the mappings only affect the current session.")
                })


                UpdateView()
                    .environmentObject(updater)

                //                Spacer()

            }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                Task {
                    await helperToolManager.manageHelperTool()
                }
                if helperToolManager.isHelperToolInstalled && showTestingUI {
                    Task {
                        let (success, output) = await helperToolManager.runCommand(commandToRun)
                        if success {
                            commandOutput = output
                        } else {
                            printOS("Helper: \(output)")
                        }
                    }
                }
            }
        }

        .frame(width: 500, height: 600, alignment: .top)
        .padding(20)

    }
}
