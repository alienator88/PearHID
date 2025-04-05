//
//  UpdateView.swift
//  PearHID
//
//  Created by Alin Lupascu on 4/4/25.
//

import Foundation
import SwiftUI
import AlinFoundation

struct UpdateView: View {
    @EnvironmentObject var updater: Updater

    var body: some View {
        VStack(spacing: 10) {

            GroupBox(label: Text("Frequency").font(.title2).padding(.bottom, 5), content: {
                FrequencyView(updater: updater)
                    .padding(5)
            })


            GroupBox(label: Text("Releases").font(.title2).padding(.bottom, 5), content: {
                RecentReleasesView(updater: updater)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            })


            HStack(alignment: .center, spacing: 20) {

                Button {
                    updater.checkForUpdates(sheet: false)
                } label: { EmptyView() }
                    .buttonStyle(SimpleButtonStyle(icon: "arrow.uturn.left.circle", label: String(localized: "Refresh"), help: String(localized: "Refresh updater")))
                    .contextMenu {
                        Button("Force Refresh") {
                            updater.checkForUpdates(sheet: true, force: true)
                        }
                    }


                Button {
                    updater.resetAnnouncementAlert()
                } label: { EmptyView() }
                    .buttonStyle(SimpleButtonStyle(icon: "star", label: String(localized: "Announcement"), help: String(localized: "Show announcements badge again")))


                Button {
                    NSWorkspace.shared.open(URL(string: "https://github.com/alienator88/PearHID/releases")!)
                } label: { EmptyView() }
                    .buttonStyle(SimpleButtonStyle(icon: "link", label: String(localized: "Releases"), help: String(localized: "View releases on GitHub")))
            }
        }
    }
}
