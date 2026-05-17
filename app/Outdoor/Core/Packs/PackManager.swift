import Foundation
import SwiftUI

/// Loads and exposes installed packs. v1 scans the app bundle for a
/// `Resources/Packs/` folder shipped with the app. Phase 2 of the build plan
/// adds a real installer that writes into `Library/Packs/` from downloaded
/// .trailpack files.
@MainActor
final class PackManager: ObservableObject {

    @Published private(set) var installed: [InstalledPack] = []
    @Published private(set) var available: [PackPreview] = []
    @Published private(set) var activePackID: String? = nil
    @Published private(set) var loadError: String? = nil

    private(set) var activeDatabase: PackDatabase? = nil
    private(set) var activeSafetyRules: [SafetyRule] = []

    init() {
        loadBundledPacks()
        loadAvailableCatalog()
        if let first = installed.first {
            switchTo(first.id)
        }
    }

    // MARK: - Loading

    /// Scan the app bundle's `Packs/` directory for installed packs.
    private func loadBundledPacks() {
        guard let resourcesURL = Bundle.main.resourceURL else { return }
        let packsRoot = resourcesURL.appendingPathComponent("Packs", isDirectory: true)

        let fm = FileManager.default
        guard let entries = try? fm.contentsOfDirectory(at: packsRoot,
                                                       includingPropertiesForKeys: nil) else {
            return
        }

        var out: [InstalledPack] = []
        for dir in entries where (try? dir.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true {
            do {
                let manifestURL = dir.appendingPathComponent("manifest.yaml")
                let dbURL = dir.appendingPathComponent("pack.sqlite")
                guard fm.fileExists(atPath: manifestURL.path),
                      fm.fileExists(atPath: dbURL.path) else { continue }

                let manifestText = try String(contentsOf: manifestURL, encoding: .utf8)
                let manifest = MiniYAML.parseManifest(manifestText)
                out.append(InstalledPack(
                    manifest: manifest,
                    rootURL: dir,
                    packDatabaseURL: dbURL
                ))
            } catch {
                continue
            }
        }
        self.installed = out.sorted { $0.manifest.displayName < $1.manifest.displayName }
    }

    private func loadAvailableCatalog() {
        // Hardcoded preview cards for "coming soon" packs. Replaced by a
        // signed remote catalog manifest in Phase 6 (Additional packs).
        self.available = [
            PackPreview(id: "hiking", displayName: "Hiking",
                        description: "Trail technique, blisters, river crossings, elevation, regional add-ons.",
                        symbol: "figure.hiking", tint: "#4A86A8"),
            PackPreview(id: "fishing", displayName: "Fishing",
                        description: "Knots, water reading, species ID disclaimer, casting fundamentals.",
                        symbol: "fish.fill", tint: "#5B8DA8"),
            PackPreview(id: "alpine", displayName: "Alpine",
                        description: "Self-arrest, glacier travel basics, altitude illness, weather windows.",
                        symbol: "mountain.2.fill", tint: "#6E5A8A"),
            PackPreview(id: "desert", displayName: "Desert Southwest",
                        description: "Heat, water sources, wash navigation, regional wildlife and plants.",
                        symbol: "sun.max.fill", tint: "#D9A24A"),
        ]
    }

    // MARK: - Active pack

    func switchTo(_ packID: String) {
        guard let pack = installed.first(where: { $0.id == packID }) else { return }
        do {
            let db = try PackDatabase(packDatabaseURL: pack.packDatabaseURL)
            self.activeDatabase = db
            self.activePackID = pack.id

            // Load safety rules alongside the pack.
            let rulesURL = pack.rootURL.appendingPathComponent("safety_rules.yaml")
            if let text = try? String(contentsOf: rulesURL, encoding: .utf8) {
                self.activeSafetyRules = MiniYAML.parseSafetyRules(text)
            } else {
                self.activeSafetyRules = []
            }
            self.loadError = nil
        } catch {
            self.loadError = "Could not open \(pack.id): \(error)"
        }
    }

    var activePack: InstalledPack? {
        guard let id = activePackID else { return nil }
        return installed.first(where: { $0.id == id })
    }
}
