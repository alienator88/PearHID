//
//  Untitled.swift
//  PearHID
//
//  Created by Alin Lupascu on 12/20/24.
//
import Foundation
import AppKit
import AlinFoundation
import SwiftUI

func checkAndRequestAccessibilityPermission() {
    if !isAccessibilityGranted() {
        // Show alert to the user
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission"
        alert.informativeText = "\(Bundle.main.name) needs Accessibility permission to set hidutil properties."
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Open the Accessibility System Settings pane
            openAccessibilitySettings()
        }
    }
}

func isAccessibilityGranted() -> Bool {
    let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: false]
    return AXIsProcessTrustedWithOptions(options)
}

func openAccessibilitySettings() {
    let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
    NSWorkspace.shared.open(url)
}


func openAppSettings() {
    if #available(macOS 14.0, *) {
        @Environment(\.openSettings) var openSettings
        openSettings()
    } else {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}
