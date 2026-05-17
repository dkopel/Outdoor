import SwiftUI

@main
struct OutdoorApp: App {
    @StateObject private var packManager = PackManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(packManager)
                .tint(OColor.ember)
                .preferredColorScheme(nil)   // follow system
        }
    }
}
