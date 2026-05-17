import SwiftUI

/// Big-button emergency screen — reachable in ≤ 2 taps from anywhere.
/// Each tile maps to a known query that triggers a locked procedure (or
/// the highest-ranked first-aid chunk for that scenario).
struct EmergencyView: View {
    @EnvironmentObject var packManager: PackManager
    @State private var activeScenario: Scenario? = nil

    struct Scenario: Identifiable, Hashable {
        let id: String
        let title: String
        let subtitle: String
        let symbol: String
        let tint: Color
        let query: String
    }

    private let scenarios: [Scenario] = [
        Scenario(id: "bleeding", title: "Bleeding",
                 subtitle: "Severe / spurting",
                 symbol: "drop.triangle.fill",
                 tint: OColor.hazardCritical,
                 query: "severe bleeding control"),
        Scenario(id: "hypothermia", title: "Hypothermia",
                 subtitle: "Cold exposure",
                 symbol: "snowflake",
                 tint: OColor.sky,
                 query: "treating hypothermia"),
        Scenario(id: "heat-stroke", title: "Heat stroke",
                 subtitle: "Confusion in heat",
                 symbol: "thermometer.sun.fill",
                 tint: OColor.hazardHigh,
                 query: "heat stroke treatment"),
        Scenario(id: "bear", title: "Bear encounter",
                 subtitle: "Predator response",
                 symbol: "pawprint.fill",
                 tint: OColor.spruce,
                 query: "what to do if a bear charges"),
        Scenario(id: "lightning", title: "Lightning",
                 subtitle: "Storm overhead",
                 symbol: "bolt.fill",
                 tint: OColor.hazardMedium,
                 query: "lightning safety position"),
        Scenario(id: "lost", title: "Lost",
                 subtitle: "Signal & shelter",
                 symbol: "questionmark.circle.fill",
                 tint: OColor.lichen,
                 query: "I am lost what should I do"),
        Scenario(id: "snake", title: "Snake bite",
                 subtitle: "Treatment & evacuation",
                 symbol: "allergens.fill",
                 tint: OColor.hazardHigh,
                 query: "snake bite first aid"),
        Scenario(id: "fall", title: "Fall / fracture",
                 subtitle: "Splinting & evac",
                 symbol: "figure.fall",
                 tint: OColor.hazardHigh,
                 query: "suspected fracture splinting"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: OSpace.l) {
                    intro
                    grid
                    callout
                    Spacer(minLength: OSpace.xl)
                }
                .padding(.top, OSpace.s)
                .padding(.bottom, OSpace.xxxl)
            }
            .background(OColor.background.ignoresSafeArea())
            .navigationTitle("Emergency")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $activeScenario) { sc in
                EmergencyProcedureSheet(scenario: sc)
                    .environmentObject(packManager)
            }
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: OSpace.xs) {
            HStack(spacing: OSpace.xs) {
                Image(systemName: "exclamationmark.shield.fill")
                    .foregroundStyle(OColor.hazardCritical)
                Text("Emergency reference")
                    .font(OType.labelM)
                    .foregroundStyle(OColor.hazardCritical)
            }
            Text("Pick the situation.\nLarge type, simple steps.")
                .font(OType.displayM)
                .foregroundStyle(OColor.text)
                .lineSpacing(2)
            Text("If anyone has signal, call emergency services first. If you have a PLB or satellite messenger, activate it.")
                .font(OType.body)
                .foregroundStyle(OColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, OSpace.m)
    }

    private var grid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: OSpace.s), GridItem(.flexible(), spacing: OSpace.s)],
                  spacing: OSpace.s) {
            ForEach(scenarios) { sc in
                EmergencyTile(scenario: sc) {
                    activeScenario = sc
                }
            }
        }
        .padding(.horizontal, OSpace.m)
    }

    private var callout: some View {
        VStack(alignment: .leading, spacing: OSpace.xs) {
            HStack(spacing: OSpace.xs) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(OColor.sky)
                Text("How emergency mode works")
                    .font(OType.labelL)
                    .foregroundStyle(OColor.text)
            }
            Text("These tiles bypass the AI and pull straight from the locked first-aid procedures in your pack. No interpretation, no guessing — just the steps as written. This guidance is not a substitute for trained care.")
                .font(OType.bodySmall)
                .foregroundStyle(OColor.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(OSpace.m)
        .background(OColor.surfaceMuted, in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
        .padding(.horizontal, OSpace.m)
    }
}

/// One emergency-scenario tile. Big touch target, high-contrast tint.
struct EmergencyTile: View {
    let scenario: EmergencyView.Scenario
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: OSpace.s) {
                ZStack {
                    Circle().fill(scenario.tint.opacity(0.15))
                    Image(systemName: scenario.symbol)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(scenario.tint)
                }
                .frame(width: 48, height: 48)

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 2) {
                    Text(scenario.title)
                        .font(OType.h2)
                        .foregroundStyle(OColor.text)
                    Text(scenario.subtitle)
                        .font(OType.caption)
                        .foregroundStyle(OColor.textSecondary)
                }
            }
            .padding(OSpace.m)
            .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
            .background(OColor.surface, in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                    .strokeBorder(scenario.tint.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: scenario.tint.opacity(0.10), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }
}

/// Sheet that renders the locked-procedure chunks for an emergency scenario.
struct EmergencyProcedureSheet: View {
    @EnvironmentObject var packManager: PackManager
    @Environment(\.dismiss) private var dismiss
    let scenario: EmergencyView.Scenario

    @State private var chunks: [RetrievedChunk] = []
    @State private var decision: RouteDecision = .general

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: OSpace.l) {
                    header

                    if !decision.mustInclude.isEmpty {
                        safetyBox
                    }

                    ForEach(chunks) { rc in
                        chunkCard(rc)
                    }
                    Spacer(minLength: 0)
                }
                .padding(OSpace.l)
            }
            .background(OColor.background)
            .navigationTitle(scenario.title)
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
            .onAppear(perform: load)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        HStack(spacing: OSpace.s) {
            ZStack {
                Circle().fill(scenario.tint.opacity(0.15))
                Image(systemName: scenario.symbol)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(scenario.tint)
            }
            .frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 2) {
                Text("Locked procedure")
                    .font(OType.labelS)
                    .foregroundStyle(scenario.tint)
                Text(scenario.title)
                    .font(OType.h1)
                    .foregroundStyle(OColor.text)
            }
            Spacer(minLength: 0)
        }
    }

    private var safetyBox: some View {
        VStack(alignment: .leading, spacing: OSpace.xs) {
            HStack(spacing: OSpace.xs) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(OColor.hazardCritical)
                Text("Before anything else")
                    .font(OType.labelM)
                    .foregroundStyle(OColor.hazardCritical)
            }
            ForEach(decision.mustInclude, id: \.self) { line in
                HStack(alignment: .top, spacing: 6) {
                    Text("•").foregroundStyle(OColor.hazardCritical)
                    Text(line)
                        .font(OType.body)
                        .foregroundStyle(OColor.text)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(OSpace.m)
        .background(OColor.hazardCritical.opacity(0.08), in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                .strokeBorder(OColor.hazardCritical.opacity(0.30), lineWidth: 1)
        )
    }

    private func chunkCard(_ rc: RetrievedChunk) -> some View {
        VStack(alignment: .leading, spacing: OSpace.xs) {
            HStack {
                Text(rc.sectionTitle)
                    .font(OType.h2)
                    .foregroundStyle(OColor.text)
                Spacer(minLength: 0)
                HazardBadge(level: rc.hazardLevel)
            }
            Text(rc.text)
                .font(OType.bodyLarge)
                .foregroundStyle(OColor.text)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
            CitationChip(chunk: rc)
                .padding(.top, 4)
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
        let service = RetrievalService(
            retriever: FTS5Retriever(database: db),
            safetyRules: packManager.activeSafetyRules
        )
        Task { @MainActor in
            let result = await service.answer(scenario.query, k: 4)
            self.decision = result.decision
            self.chunks = result.chunks
        }
    }
}

#Preview {
    EmergencyView().environmentObject(PackManager())
}
