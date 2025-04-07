//
//  Styles.swift
//  PearHID
//
//  Created by Alin Lupascu on 4/4/25.
//

import SwiftUI
import Foundation
import AlinFoundation

struct HelperBadge: View {

    var body: some View {
        AlertNotification(label: "Enable Helper", icon: "lock", buttonAction: {
            openAppSettings()
        }, btnColor: Color.blue, hideLabel: true)

    }
}

struct CheckmarkOverlay: View {
    @Binding var show: Bool

    var body: some View {
        if show {
            Image(systemName: "checkmark")
            .font(.title)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .transition(.scale)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        show = false
                    }
                }
            }
        }
    }
}
