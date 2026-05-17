import SwiftUI

/// Minimal settings view — expanded in Phase 5 (storage management, model
/// selection, accessibility). Kept in the tree so the structure is real and
/// future work has a clear home.
struct SettingsView: View {
    @EnvironmentObject var packManager: PackManager
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false
    @State private var showOnboarding = false

    var body: some View {
        NavigationStack {
            List {
                Section("Active pack") {
                    if let pack = packManager.activePack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pack.manifest.displayName).font(OType.labelL)
                            Text("v\(pack.manifest.version) · \(pack.manifest.chunkCount) chunks")
                                .font(OType.caption).foregroundStyle(OColor.textSecondary)
                        }
                    } else {
                        Text("No pack installed").foregroundStyle(OColor.textTertiary)
                    }
                }

                Section("Privacy") {
                    Label("All retrieval runs on-device", systemImage: "lock.shield.fill")
                    Label("Nothing is sent to a network", systemImage: "wifi.slash")
                }

                Section("Diagnostics") {
                    Button {
                        showOnboarding = true
                    } label: {
                        Label("Run offline check again", systemImage: "antenna.radiowaves.left.and.right.slash")
                    }
                }

                Section("About") {
                    LabeledContent("App version", value: appVersion)
                }
            }
            .navigationTitle("Settings")
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView(onComplete: { showOnboarding = false })
                    .environmentObject(packManager)
            }
        }
    }

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        return v
    }
}
