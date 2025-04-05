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
        AlertNotification(label: "Helper Not Installed".localized(), icon: "key", buttonAction: {
            openAppSettings()
        }, btnColor: Color.orange, hideLabel: false)

    }
}
