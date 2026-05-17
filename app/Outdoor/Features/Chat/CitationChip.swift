import SwiftUI

/// Tappable chip showing the source of a chunk. Tapping opens a sheet with the
/// full chunk text + source metadata.
struct CitationChip: View {
    let chunk: RetrievedChunk
    @State private var showDetail = false

    var body: some View {
        Button {
            showDetail = true
        } label: {
            HStack(spacing: 6) {
                DomainIcon(domain: chunk.chunk.domain, size: 18)
                Text(chunk.chunk.citationLabel)
                    .font(OType.labelS)
                    .lineLimit(1)
                Image(systemName: "chevron.up.right")
                    .font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(OColor.text)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(OColor.surface, in: RoundedRectangle(cornerRadius: ORadius.chip, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ORadius.chip, style: .continuous)
                    .strokeBorder(OColor.separator, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            CitationDetailView(chunk: chunk.chunk)
        }
    }
}

struct CitationDetailView: View {
    let chunk: Chunk
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: OSpace.l) {
                    HStack(spacing: OSpace.s) {
                        DomainIcon(domain: chunk.domain, size: 36)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(chunk.domain.domainDisplayName)
                                .font(OType.labelM)
                                .foregroundStyle(OColor.textSecondary)
                            Text(chunk.sectionTitle)
                                .font(OType.h1)
                                .foregroundStyle(OColor.text)
                        }
                    }

                    if chunk.hazardLevel != "low" {
                        HazardBadge(level: chunk.hazardLevel)
                    }

                    Text(chunk.text)
                        .font(OType.bodyLarge)
                        .foregroundStyle(OColor.text)
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
                            HStack(spacing: OSpace.xs) {
                                OPill(icon: "doc.text", text: chunk.sourceLicense.isEmpty ? "—" : chunk.sourceLicense,
                                      tint: OColor.spruce)
                                OPill(icon: "tag.fill", text: chunk.id, tint: OColor.textSecondary)
                            }
                            .padding(.top, 4)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(OSpace.l)
            }
            .background(OColor.background)
            .navigationTitle("Citation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(OColor.textTertiary)
                            .font(.system(size: 22))
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
