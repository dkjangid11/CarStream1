//
//  MainView.swift
//  CarStream
//

import SwiftUI
import ReplayKit

struct MainView: View {
    @State private var accessToken: String = ""
    @ObservedObject var videoAPI = CarStreamVideoAPI.shared
    @State private var showingCodeAlert = false
    @State private var connectionCode = ""
    @State private var showRebootAlert = false
    @State var isStationary = false
    @StateObject private var locationAPI = CarStreamLocationAPI.shared

    var body: some View {
        TabView {
            NavigationStack {
                homeContent
                    .navigationTitle("CarStream")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Enter Code") {
                                showingCodeAlert = true
                            }
                        }
                    }
                    .alert("Enter Connection Code", isPresented: $showingCodeAlert, actions: {
                        TextField("Connection Code", text: $connectionCode)
                        Button("OK") {
                            if connectionCode.lowercased() == "carplay" {
                                // Trigger reboot instruction
                                CarStreamAccess.shared.DisableIsStationary = true
                                showRebootAlert = true
                            }
                            connectionCode = ""
                        }
                        Button("Cancel", role: .cancel) {
                            connectionCode = ""
                        }
                    }, message: {
                        Text("Enter the connection code to proceed.")
                    })
                    .alert("Reboot Required", isPresented: $showRebootAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("CarPlay mode is now enabled. Please close and reopen the app for changes to take effect.")
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                WebViewContainer()
            }
            .tabItem {
                Label("Browser", systemImage: "safari")
            }

            NavigationStack {
                WebViewButtons()
            }
            .tabItem {
                Label("Controls", systemImage: "slider.horizontal.3")
            }

            AppSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }

    private var homeContent: some View {
        List {
            Section(header: Text("Getting Started")) {
                Text("IOS 26 IS NOT SUPPORTED")
                    .tint(.red)
                    .fontWeight(.bold)
                NavigationLink(destination: Help()) {
                    Label("Help", systemImage: "questionmark.circle")
                }

                Button(action: openYouTubeHelp) {
                    Label("Watch Help Video", systemImage: "play.rectangle.fill")
                        .foregroundColor(.blue)
                        .bold()
                }
            }

            Section(header: Text("Screen Mirroring & Web")) {
                NavigationLink(destination: ScreenMirroingSettings()) {
                    Label("Screen Mirroring Settings", systemImage: "rectangle.on.rectangle")
                }
                NavigationLink(destination: ScreenMirroringView()) {
                    Label("View Screen Mirroring", systemImage: "rectangle.on.rectangle")
                }

                Button(action: openYouTubeInCar) {
                    Label("YouTube on CarPlay", systemImage: "play.rectangle.fill")
                }

                NavigationLink(destination: WebServerPage()) {
                    Label("HTTP server", systemImage: "safari")
                }

                Button(action: {
                    CarStreamVideoShared.shared.CarPlayComp?(.init(type: .web, URL: nil))
                }) {
                    Label("Load Web in Car", systemImage: "car.fill")
                }

                NavigationLink(destination: SingleVideoPicker()) {
                    Label("Stream Video Files", systemImage: "film.stack")
                }
            }

            Section(footer:
                VStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Text("Built with ❤️ for CarPlay by")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("@dkjangid")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.blue)
                    }

                    Text("© 2026 CarStream iOS. All rights reserved.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            ) {
                EmptyView()
            }
        }
    }

    // MARK: - Actions

    func openYouTubeHelp() {
        openURL("https://youtu.be/gI3Tj2KP290")
    }

    func openYouTubeInCar() {
        CustomWebViewController.shared.loadURL(CustomWebViewController.youtubeURL)
        CarStreamVideoShared.shared.CarPlayComp?(.init(type: .web, URL: CustomWebViewController.youtubeURL))
    }

    func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    MainView()
}
