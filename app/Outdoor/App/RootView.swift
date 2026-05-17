import SwiftUI

enum RootTab: Hashable {
    case chat, guideBrowse, emergency, catalog
}

/// Top-level tab navigation. Five-tap rule: any safety-critical action must
/// be reachable in ≤ 2 taps from anywhere. Emergency is its own tab.
///
/// On first launch we present `OnboardingView` as a full-screen cover that
/// walks through Welcome → Your pack → Verify offline. The flag is stored in
/// `UserDefaults` via `@AppStorage` so it sticks across launches.
struct RootView: View {
    @State private var tab: RootTab = .chat
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false

    var body: some View {
        TabView(selection: $tab) {
            ChatView()
                .tabItem { Label("Ask", systemImage: "bubble.left.and.text.bubble.right.fill") }
                .tag(RootTab.chat)

            GuideView()
                .tabItem { Label("Guide", systemImage: "books.vertical.fill") }
                .tag(RootTab.guideBrowse)

            EmergencyView()
                .tabItem { Label("Emergency", systemImage: "cross.case.fill") }
                .tag(RootTab.emergency)

            PackCatalogView()
                .tabItem { Label("Packs", systemImage: "square.stack.3d.up.fill") }
                .tag(RootTab.catalog)
        }
        .background(OColor.background.ignoresSafeArea())
        .fullScreenCover(isPresented: .init(
            get: { !hasOnboarded },
            set: { presenting in if !presenting { hasOnboarded = true } }
        )) {
            OnboardingView()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(PackManager())
}
