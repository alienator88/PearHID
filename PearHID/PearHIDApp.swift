//
//  PearHIDApp.swift
//  PearHID
//
//  Created by Alin Lupascu on 12/20/24.
//

import SwiftUI
import AlinFoundation

@main
struct PearHIDApp: App {
    @StateObject var viewModel = MappingsViewModel()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var updater = Updater(owner: "alienator88", repo: "PearHID")
    @State private var windowController = WindowManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(updater)
                .toolbar { Color.clear }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(after: .help) {
                Button {
                    windowController.open(with: ConsoleView(), width: 600, height: 400)
                } label: {
                    Text("Debug Console")
                }
                .keyboardShortcut("d", modifiers: .command)
            }
        }

        Settings {
            SettingsView()
                .environmentObject(updater)
                .toolbarBackground(.clear)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    func applicationDidFinishLaunching(_ notification: Notification) {
        checkAndRequestAccessibilityPermission()
    }
}
