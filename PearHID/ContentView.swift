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
    @AppStorage("settings.persistReboot") private var persistReboot: Bool = true
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
//                                if key != viewModel.mappings.indices.last {
//                                    Divider()
//                                }
                            }
                            Spacer()
                        }
                    }
                }

                HStack {
//                    Button("Clear List") {
//                        viewModel.removeAllMappings()
//                    }
//                    .buttonStyle(ColoredButtonStyle(color: .orange))
//                    .help("Remove the configured mappings from the list above (Does not affect hidutil mappings)")
//                    .disabled(viewModel.mappings.isEmpty)
//                    .opacity(viewModel.mappings.isEmpty ? 0.5 : 1)

                    Button("Reset") {
                        viewModel.clearHIDKeyMappings()
                    }
                    .buttonStyle(ColoredButtonStyle(color: .orange))
                    .disabled(viewModel.mappings.isEmpty)
                    .opacity(viewModel.mappings.isEmpty ? 0.5 : 1)
                    .help("Remove all custom HID key mappings")

                    Button("Save") {
                        viewModel.setHIDKeyMappings()
                    }
                    .buttonStyle(ColoredButtonStyle(color: .blue))
                    .help("Set HID key mappings to the configured list above")
//                    .disabled(viewModel.mappings.isEmpty)
                    .opacity(viewModel.mappings.isEmpty ? 0.5 : 1)

                    Toggle("Persist Reboot", isOn: $persistReboot)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                        .help("If this is enabled, a plist will be installed so the mappings survive reboots. Otherwise the mappings only affect the current session.")
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(20)


            // Preview Plist Content
            if showPlist {
                VStack() {
                    HStack {
                        Spacer()
                        Button(action: {
                            copyToClipboard(viewModel.generatePlist())
                        }) {
                            Image(systemName: "list.clipboard")
                                .padding(5)
                                .padding(.horizontal, 2)
                                .padding(.bottom, 1)
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .shadow(radius: 2)
                        }
                        .buttonStyle(.plain)
                        .help("Copy to clipboard")
                    }
                    .padding([.top, .trailing])
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
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.primary.opacity(0.1), lineWidth: 1)
                    }
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
                .help("Refresh custom mappings")
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
        .frame(minWidth: 640, minHeight: 450)
        .background(.primary.opacity(0.00000001))
        .onTapGesture {
            withAnimation {
                showPlist = false
            }
        }

    }
}
