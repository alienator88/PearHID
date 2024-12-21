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


struct ColoredButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 80, height: 20)
            .padding(6)
            .padding(.horizontal, 2)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .shadow(radius: 2)
            .opacity(configuration.isPressed ? 0.8 : 1.0) // Add slight opacity change when pressed
    }
}
