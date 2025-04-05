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
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var helperToolManager = HelperToolManager.shared
    @State private var windowController = WindowManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(updater)
                .environmentObject(themeManager)
                .toolbar { Color.clear }
                .onAppear {
                    checkAndRequestAccessibilityPermission()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .windowResizability(.contentSize)

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
}
