//
//  ContentView.swift
//  PearHID
//
//  Created by Alin Lupascu on 12/20/24.
//

import SwiftUI
import AlinFoundation

struct ContentView: View {
    @EnvironmentObject var viewModel: MappingsViewModel
    @State private var showPlist = false

    var body: some View {

        ZStack {

            // Configured Key Mappings
            VStack(spacing: 10) {
                if viewModel.mappings.isEmpty {
                    Spacer()
                    Text("No custom mappings added")
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(viewModel.mappings.indices, id: \.self) { key in
                                MappingRowListItem(mapping: viewModel.mappings[key])
                                // Add a divider if this is not the last item
                                if key != viewModel.mappings.indices.last {
                                    Divider()
                                }
                            }
                            Spacer()
                        }
                    }


                    if viewModel.plistLoaded {
                        Text("Custom mappings loaded from saved plist")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .padding(.top)
                    }

                }

                HStack {
                    Button("Clear List") {
                        viewModel.removeAllMappings()
                    }
                    .buttonStyle(ColoredButtonStyle(color: .orange))
                    .help("Remove all currently configured mappings from the list only")
                    .disabled(viewModel.mappings.isEmpty)
                    .opacity(viewModel.mappings.isEmpty ? 0.5 : 1)

                    Button("Clear HID") {
                        viewModel.clearHIDKeyMappings()
                    }
                    .buttonStyle(ColoredButtonStyle(color: .orange))
                    .help("Clear HID key mappings for this session only")

                    Button("Set HID") {
                        viewModel.setHIDKeyMappings()
                    }
                    .buttonStyle(ColoredButtonStyle(color: .blue))
                    .help("Set HID key mappings for this session only, restart will clear them out")
                    .disabled(viewModel.mappings.isEmpty)
                    .opacity(viewModel.mappings.isEmpty ? 0.5 : 1)

                    Button("Remove Plist") {
                        do {
                            try viewModel.removeLaunchDaemon()
                        } catch {
                            print("Error: \(error.localizedDescription)")
                        }

                    }
                    .buttonStyle(ColoredButtonStyle(color: .red))
                    .help("Remove plist from LaunchDaemons and clear keyboard mappings")
                    .disabled(!viewModel.plistLoaded)

                    Button("Apply Plist") {
                        do {
                            try viewModel.setupLaunchDaemon(plistContent: viewModel.generatePlist())
                        } catch {
                            print("Error: \(error.localizedDescription)")
                        }

                    }
                    .buttonStyle(ColoredButtonStyle(color: .green))
                    .help("Install plist in LaunchDaemons and set up keyboard mappings")
                    .disabled(viewModel.mappings.isEmpty)
                    .opacity(viewModel.mappings.isEmpty ? 0.5 : 1)
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(20)


            // Preview Plist Content
            if showPlist {
                VStack() {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            Text(viewModel.generatePlist())
                                .textSelection(.enabled)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding()
                    }
                    Spacer()
                }
                .frame(width: 400)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.primary.opacity(0.1), lineWidth: 1)
                    }
                .background(.ultraThinMaterial)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding([.trailing, .bottom])
                .transition(.move(edge: .trailing))

            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                MainMappingRowView()
            }

            ToolbarItem(placement: .automatic) {
                Button {
                    withAnimation {
                        viewModel.loadExistingMappings()
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                }
                .buttonStyle(.bordered)
                .help("Refresh mappings from local file if it exists")
            }
            ToolbarItem(placement: .automatic) {
                Button {
                    withAnimation {
                        showPlist.toggle()
                    }
                } label: {
                    Image(systemName: "sidebar.right")
                        .font(.title3)
                }
                .buttonStyle(.bordered)
                .help("Plist Preview")

            }

        }
        .frame(minWidth: 650, minHeight: 450)
        .background(.primary.opacity(0.00000001))
        .onTapGesture {
            withAnimation {
                showPlist = false
            }
        }

    }
}
