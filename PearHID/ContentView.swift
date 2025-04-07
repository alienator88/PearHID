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
    @ObservedObject private var helperToolManager = HelperToolManager.shared
    @State private var showPlist = false
    @State private var text = ""
    @State private var showCheck = false

    var body: some View {

        ZStack {

            VStack(spacing: 10) {

                Divider()
                    .padding(.bottom)

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
                            }
                            Spacer()
                        }
                    }
                }

                Divider()
                    .padding(.vertical)

                HStack {

                    if !helperToolManager.isHelperToolInstalled {
                        HelperBadge()
                            .controlSize(.small)
                        Spacer()
                    } else {
                        TextField("Test key mappings here", text: $text)
                            .textFieldStyle(.plain)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        viewModel.clearHIDKeyMappings(show: $showCheck)
                    } label: {
                        Text("Reset").padding(5)
                    }
                    .opacity(viewModel.mappings.isEmpty ? 0.5 : 1)
                    .help("Remove all custom HID key mappings")

                    Button {
                        viewModel.setHIDKeyMappings(show: $showCheck)
                    } label: {
                        Text("Save").padding(5)
                    }
                    .help("Set HID key mappings to the configured list above")
                    .opacity(viewModel.mappings.isEmpty ? 0.5 : 1)

                }



            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(20)


            // Preview Plist Content
            if showPlist {
                VStack(spacing: 5) {
                    HStack {
                        Text("PearHID.KeyMapping.plist")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.leading)

                        Spacer()

                        Button(action: {
                            NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: "/Library/LaunchDaemons/PearHID.KeyMapping.plist")])
                        }) {
                            Image(systemName: "folder")
                                .padding(5)
                                .padding(.horizontal, 2)
                                .padding(.bottom, 1)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .shadow(radius: 2)
                        }
                        .buttonStyle(.plain)
                        .help("Copy to clipboard")

                        Button(action: {
                            copyToClipboard(viewModel.generatePlist())
                        }) {
                            Image(systemName: "list.clipboard")
                                .padding(5)
                                .padding(.horizontal, 2)
                                .padding(.bottom, 1)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .shadow(radius: 2)
                        }
                        .buttonStyle(.plain)
                        .help("Copy to clipboard")
                    }
                    .padding([.top, .trailing], 5)

                    Divider()

                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            Text(viewModel.generatePlist())
                                .textSelection(.enabled)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                    }
                    Spacer()
                }
                .frame(width: 400)
                .background(.thickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(.primary.opacity(0.1), lineWidth: 1)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding([.trailing, .bottom])
                .transition(.move(edge: .trailing))

            }

            if showCheck {
                CheckmarkOverlay(show: $showCheck)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                MainMappingRowView()
            }

            ToolbarItem(placement: .automatic) {
                Button {
                    withAnimation {
                        viewModel.loadExistingMappingsFromAPI()
                        showCheck = true
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title3)
                }
                .buttonStyle(.bordered)
                .help("Reload existing mappings")
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
        .frame(minWidth: 650, minHeight: 500)
        .background(.ultraThickMaterial)
        .background(MetalView().edgesIgnoringSafeArea(.all))
        .onTapGesture {
            withAnimation {
                showPlist = false
            }
        }

    }
}
