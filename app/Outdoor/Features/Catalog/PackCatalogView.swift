import SwiftUI

struct PackCatalogView: View {
    @EnvironmentObject var packManager: PackManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: OSpace.xl) {
                    header

                    if !packManager.installed.isEmpty {
                        VStack(alignment: .leading, spacing: OSpace.s) {
                            OSectionHeader(title: "Installed", trailing: "\(packManager.installed.count)")
                            VStack(spacing: OSpace.s) {
                                ForEach(packManager.installed) { pack in
                                    InstalledPackCard(
                                        pack: pack,
                                        isActive: pack.id == packManager.activePackID,
                                        onSelect: { packManager.switchTo(pack.id) }
                                    )
                                }
                            }
                            .padding(.horizontal, OSpace.m)
                        }
                    }

                    if !packManager.available.isEmpty {
                        VStack(alignment: .leading, spacing: OSpace.s) {
                            OSectionHeader(title: "More packs", trailing: "Coming soon")
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: OSpace.s),
                                GridItem(.flexible(), spacing: OSpace.s)
                            ], spacing: OSpace.s) {
                                ForEach(packManager.available, id: \.id) { p in
                                    AvailablePackCard(preview: p)
                                }
                            }
                            .padding(.horizontal, OSpace.m)
                        }
                    }

                    aboutCard
                        .padding(.horizontal, OSpace.m)

                    Spacer(minLength: OSpace.xl)
                }
                .padding(.top, OSpace.s)
                .padding(.bottom, OSpace.xxl)
            }
            .background(OColor.background.ignoresSafeArea())
            .navigationTitle("Packs")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: OSpace.xs) {
            Text("Your offline library")
                .font(OType.bodyLarge)
                .foregroundStyle(OColor.textSecondary)
            Text("Download a pack before each trip. Use it without signal in the field.")
                .font(OType.bodySmall)
                .foregroundStyle(OColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, OSpace.m)
        .padding(.top, OSpace.xs)
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: OSpace.xs) {
            HStack(spacing: OSpace.xs) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(OColor.sky)
                Text("About your packs")
                    .font(OType.labelL)
                    .foregroundStyle(OColor.text)
            }
            Text("Every chunk in a pack is tied to a source you can verify. Safety-critical topics — first aid, edible plants — use locked procedures, not AI guesses. The app never sends your questions anywhere.")
                .font(OType.bodySmall)
                .foregroundStyle(OColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(OSpace.m)
        .background(OColor.surfaceMuted, in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
    }
}

#Preview {
    PackCatalogView().environmentObject(PackManager())
}
