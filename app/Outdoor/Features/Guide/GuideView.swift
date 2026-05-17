import SwiftUI

/// Browse the active pack by domain. The chat is for "I have a question",
/// the guide is for "let me see what's in here."
struct GuideView: View {
    @EnvironmentObject var packManager: PackManager

    private var domains: [String] {
        packManager.activePack?.manifest.domains ?? []
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: OSpace.l) {
                    header

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: OSpace.s),
                        GridItem(.flexible(), spacing: OSpace.s)
                    ], spacing: OSpace.s) {
                        ForEach(domains, id: \.self) { d in
                            NavigationLink(value: d) {
                                DomainCard(domain: d)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, OSpace.m)

                    Spacer(minLength: OSpace.xxl)
                }
                .padding(.top, OSpace.s)
            }
            .background(OColor.background.ignoresSafeArea())
            .navigationTitle("Guide")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: String.self) { domain in
                DomainListView(domain: domain)
                    .environmentObject(packManager)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Browse by topic")
                .font(OType.bodyLarge)
                .foregroundStyle(OColor.textSecondary)
            Text("Twelve domains in your camping pack.")
                .font(OType.bodySmall)
                .foregroundStyle(OColor.textSecondary)
        }
        .padding(.horizontal, OSpace.m)
    }
}

private struct DomainCard: View {
    let domain: String
    var body: some View {
        VStack(alignment: .leading, spacing: OSpace.s) {
            DomainIcon(domain: domain, size: 40)
            Text(domain.domainDisplayName)
                .font(OType.h3)
                .foregroundStyle(OColor.text)
            Spacer(minLength: 0)
            HStack(spacing: 4) {
                Text("Browse")
                    .font(OType.labelS)
                    .foregroundStyle(OColor.textSecondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(OColor.textSecondary)
            }
        }
        .padding(OSpace.m)
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
        .background(OColor.surface, in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                .strokeBorder(OColor.separator, lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
    }
}

struct DomainListView: View {
    let domain: String
    @EnvironmentObject var packManager: PackManager
    @State private var topics: [RetrievedChunk] = []

    var body: some View {
        ScrollView {
            VStack(spacing: OSpace.s) {
                ForEach(topics) { c in
                    NavigationLink(value: c) {
                        topicRow(c)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(OSpace.m)
        }
        .background(OColor.background.ignoresSafeArea())
        .navigationTitle(domain.domainDisplayName)
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: RetrievedChunk.self) { c in
            ChunkDetailView(chunk: c).environmentObject(packManager)
        }
        .onAppear(perform: load)
    }

    private func topicRow(_ c: RetrievedChunk) -> some View {
        HStack(spacing: OSpace.s) {
            DomainIcon(domain: c.domain, size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text((c.topic ?? c.sectionTitle).capitalized)
                    .font(OType.h3)
                    .foregroundStyle(OColor.text)
                Text(c.text)
                    .font(OType.bodySmall)
                    .foregroundStyle(OColor.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            if c.hazardLevel == .high || c.hazardLevel == .critical {
                HazardBadge(level: c.hazardLevel)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(OColor.textTertiary)
        }
        .padding(OSpace.m)
        .background(OColor.surface, in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                .strokeBorder(OColor.separator, lineWidth: 0.5)
        )
    }

    private func load() {
        guard let db = packManager.activeDatabase else { return }
        if let rows = try? db.topicsInDomain(domain) {
            self.topics = rows
        }
    }
}

struct ChunkDetailView: View {
    let chunk: RetrievedChunk
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OSpace.l) {
                HStack(spacing: OSpace.s) {
                    DomainIcon(domain: chunk.domain, size: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chunk.domain.domainDisplayName)
                            .font(OType.labelM)
                            .foregroundStyle(OColor.textSecondary)
                        Text(chunk.sectionTitle)
                            .font(OType.h1)
                            .foregroundStyle(OColor.text)
                    }
                }
                if chunk.hazardLevel != .low {
                    HazardBadge(level: chunk.hazardLevel)
                }
                Text(chunk.text)
                    .font(OType.bodyLarge)
                    .foregroundStyle(OColor.text)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                OCard(tint: OColor.surfaceMuted) {
                    VStack(alignment: .leading, spacing: OSpace.xs) {
                        Text("Source")
                            .font(OType.labelS)
                            .foregroundStyle(OColor.textSecondary)
                        Text(chunk.sourceTitle.isEmpty ? "—" : chunk.sourceTitle)
                            .font(OType.h3)
                            .foregroundStyle(OColor.text)
                        if !chunk.sourcePublisher.isEmpty {
                            Text(chunk.sourcePublisher)
                                .font(OType.bodySmall)
                                .foregroundStyle(OColor.textSecondary)
                        }
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(OSpace.l)
        }
        .background(OColor.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}
