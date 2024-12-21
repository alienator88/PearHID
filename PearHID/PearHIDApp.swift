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
    @StateObject private var themeManager = ThemeManager.shared
    @State private var windowController = WindowManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(updater)
                .environmentObject(themeManager)
                .toolbar { Color.clear }
                .onAppear {
                    checkAndRequestAccessibilityPermission()
//                    windowController.open(with: ConsoleView(), width: 600, height: 400)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .windowResizability(.contentSize)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
