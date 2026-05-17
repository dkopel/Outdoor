import SwiftUI

/// First-launch flow. Three pages: Welcome, Your Pack, Verify Offline.
/// The final page runs a real FTS5 query against the bundled camping pack
/// in airplane mode, proving the app actually works without a network.
struct OnboardingView: View {
    @EnvironmentObject var packManager: PackManager
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false
    @State private var page: Int = 0

    /// Optional explicit dismissal — if nil, we set @AppStorage to mark done.
    var onComplete: (() -> Void)? = nil

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, OSpace.m)
                    .padding(.top, OSpace.s)

                TabView(selection: $page) {
                    WelcomePage().tag(0)
                    PackPage().tag(1)
                    VerifyOfflinePage(onContinue: complete).tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(OMotion.soft, value: page)

                pageIndicator
                    .padding(.bottom, OSpace.m)

                if page < 2 {
                    Button {
                        withAnimation(OMotion.soft) { page += 1 }
                    } label: {
                        Text(page == 0 ? "Get started" : "Next")
                    }
                    .buttonStyle(.o(.primary, size: .large, fullWidth: true))
                    .padding(.horizontal, OSpace.m)
                    .padding(.bottom, OSpace.l)
                }
            }
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Spacer()
            if page < 2 {
                Button {
                    complete()
                } label: {
                    Text("Skip")
                        .font(OType.labelM)
                        .foregroundStyle(OColor.textSecondary)
                }
            }
        }
        .frame(minHeight: 32)
    }

    // MARK: - Page indicator

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i == page ? OColor.ember : OColor.separator)
                    .frame(width: i == page ? 24 : 8, height: 8)
                    .animation(OMotion.soft, value: page)
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                OColor.spruce.opacity(0.16),
                OColor.ember.opacity(0.08),
                OColor.background
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func complete() {
        hasOnboarded = true
        onComplete?()
    }
}

// MARK: - Page 1: Welcome

private struct WelcomePage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: OSpace.l) {
            Spacer()
            ZStack {
                Circle()
                    .fill(OColor.spruce.opacity(0.10))
                    .frame(width: 200, height: 200)
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 96, weight: .semibold))
                    .foregroundStyle(OColor.spruce)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: OSpace.s) {
                Text("Outdoor")
                    .font(OType.displayXL)
                    .foregroundStyle(OColor.text)
                Text("Your trusted offline\nfield guide.")
                    .font(OType.displayM)
                    .foregroundStyle(OColor.textSecondary)
                    .lineSpacing(2)
                Text("Ask anything from your pack — first aid, knots, water, wildlife, weather. Works deep in the backcountry with no signal.")
                    .font(OType.body)
                    .foregroundStyle(OColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, OSpace.xs)
            }
            Spacer(minLength: OSpace.xxl)
        }
        .padding(.horizontal, OSpace.l)
    }
}

// MARK: - Page 2: Your Pack

private struct PackPage: View {
    @EnvironmentObject var packManager: PackManager

    var body: some View {
        VStack(alignment: .leading, spacing: OSpace.l) {
            Spacer(minLength: 0)

            ZStack {
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(OColor.spruce.opacity(0.10))
                    .frame(width: 160, height: 160)
                Image(systemName: "tent.fill")
                    .font(.system(size: 78, weight: .semibold))
                    .foregroundStyle(OColor.spruce)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: OSpace.s) {
                Text("Your camping pack")
                    .font(OType.displayM)
                    .foregroundStyle(OColor.text)
                Text("We've installed the Camping pack — it covers first aid, knots, fire, navigation, wildlife encounters, and more. Every answer cites the source you can read in full.")
                    .font(OType.body)
                    .foregroundStyle(OColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let pack = packManager.activePack {
                packSummaryCard(pack)
            }

            Spacer(minLength: OSpace.xl)
        }
        .padding(.horizontal, OSpace.l)
    }

    private func packSummaryCard(_ pack: InstalledPack) -> some View {
        HStack(spacing: OSpace.s) {
            ZStack {
                Circle().fill(OColor.spruce.opacity(0.15))
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(OColor.spruce)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(pack.manifest.displayName)
                    .font(OType.labelL)
                    .foregroundStyle(OColor.text)
                Text("\(pack.manifest.chunkCount) chunks · \(pack.manifest.sourceCount) sources · ready offline")
                    .font(OType.caption)
                    .foregroundStyle(OColor.textSecondary)
            }
            Spacer(minLength: 0)
            Image(systemName: "wifi.slash")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(OColor.spruce)
                .padding(8)
                .background(OColor.spruce.opacity(0.10), in: Circle())
        }
        .padding(OSpace.m)
        .background(OColor.surface, in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                .strokeBorder(OColor.separator, lineWidth: 0.5)
        )
    }
}

// MARK: - Page 3: Verify Offline

private struct VerifyOfflinePage: View {
    @EnvironmentObject var packManager: PackManager
    let onContinue: () -> Void

    enum State: Equatable {
        case idle
        case checking
        case passed(sectionTitle: String, sourceName: String)
        case failed(reason: String)
    }

    @State private var state: State = .idle

    private let testQuery = "how do I purify water"

    var body: some View {
        VStack(alignment: .leading, spacing: OSpace.l) {
            Spacer(minLength: 0)
            ZStack {
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(OColor.ember.opacity(0.12))
                    .frame(width: 160, height: 160)
                Image(systemName: "wifi.slash")
                    .font(.system(size: 70, weight: .semibold))
                    .foregroundStyle(OColor.ember)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: OSpace.s) {
                Text("Prove it works offline")
                    .font(OType.displayM)
                    .foregroundStyle(OColor.text)
                Text("Turn on **Airplane Mode** now, then tap Verify. We'll run a real query against your pack — if it answers, you're ready for the backcountry.")
                    .font(OType.body)
                    .foregroundStyle(OColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            statusCard

            Spacer(minLength: 0)

            VStack(spacing: OSpace.s) {
                primaryButton

                if case .passed = state {
                    Text("Tip: long flights are a great time to download more packs while you have Wi-Fi.")
                        .font(OType.caption)
                        .foregroundStyle(OColor.textTertiary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, OSpace.l)
        }
        .padding(.horizontal, OSpace.l)
    }

    // MARK: Status card

    @ViewBuilder
    private var statusCard: some View {
        switch state {
        case .idle:
            idleCard
        case .checking:
            checkingCard
        case .passed(let title, let source):
            passedCard(title: title, source: source)
        case .failed(let reason):
            failedCard(reason: reason)
        }
    }

    private var idleCard: some View {
        HStack(spacing: OSpace.s) {
            Image(systemName: "airplane")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(OColor.ember)
                .padding(10)
                .background(OColor.ember.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text("Ready to check")
                    .font(OType.labelL)
                    .foregroundStyle(OColor.text)
                Text("Test query: \"\(testQuery)\"")
                    .font(OType.caption)
                    .foregroundStyle(OColor.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(OSpace.m)
        .background(OColor.surface, in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                .strokeBorder(OColor.separator, lineWidth: 0.5)
        )
    }

    private var checkingCard: some View {
        HStack(spacing: OSpace.s) {
            TypingDotsView()
                .frame(width: 28)
            Text("Running the test query against your pack…")
                .font(OType.body)
                .foregroundStyle(OColor.text)
            Spacer(minLength: 0)
        }
        .padding(OSpace.m)
        .background(OColor.surface, in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                .strokeBorder(OColor.separator, lineWidth: 0.5)
        )
    }

    private func passedCard(title: String, source: String) -> some View {
        HStack(alignment: .top, spacing: OSpace.s) {
            ZStack {
                Circle().fill(OColor.spruce.opacity(0.15))
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(OColor.spruce)
            }
            .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text("Offline check passed")
                    .font(OType.labelL)
                    .foregroundStyle(OColor.spruce)
                Text("Top result: \(title)")
                    .font(OType.bodySmall)
                    .foregroundStyle(OColor.text)
                Text("Source: \(source)")
                    .font(OType.caption)
                    .foregroundStyle(OColor.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(OSpace.m)
        .background(OColor.spruce.opacity(0.06),
                    in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                .strokeBorder(OColor.spruce.opacity(0.30), lineWidth: 1)
        )
    }

    private func failedCard(reason: String) -> some View {
        HStack(alignment: .top, spacing: OSpace.s) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(OColor.hazardCritical)
            VStack(alignment: .leading, spacing: 2) {
                Text("Something's off")
                    .font(OType.labelL)
                    .foregroundStyle(OColor.hazardCritical)
                Text(reason)
                    .font(OType.bodySmall)
                    .foregroundStyle(OColor.text)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(OSpace.m)
        .background(OColor.hazardCritical.opacity(0.06),
                    in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                .strokeBorder(OColor.hazardCritical.opacity(0.30), lineWidth: 1)
        )
    }

    // MARK: Primary action

    @ViewBuilder
    private var primaryButton: some View {
        switch state {
        case .idle, .failed:
            Button {
                runCheck()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                    Text("Verify offline")
                }
            }
            .buttonStyle(.o(.primary, size: .large, fullWidth: true))

        case .checking:
            Button {} label: { Text("Checking…") }
                .buttonStyle(.o(.primary, size: .large, fullWidth: true))
                .disabled(true)

        case .passed:
            Button {
                onContinue()
            } label: {
                HStack(spacing: 8) {
                    Text("Start using Outdoor")
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle(.o(.primary, size: .large, fullWidth: true))
        }
    }

    private func runCheck() {
        guard let db = packManager.activeDatabase else {
            state = .failed(reason: "No pack found. The Camping pack should have been bundled. Reinstall the app or contact support.")
            return
        }
        state = .checking
        let service = RetrievalService(
            retriever: FTS5Retriever(database: db),
            safetyRules: packManager.activeSafetyRules
        )
        Task { @MainActor in
            // Tiny delay so the checking state gets a beat of UI time even
            // though FTS queries finish in microseconds.
            try? await Task.sleep(nanoseconds: 700_000_000)
            let result = await service.answer(testQuery, k: 1)
            if let top = result.chunks.first {
                state = .passed(
                    sectionTitle: top.sectionTitle,
                    sourceName: top.sourcePublisher.isEmpty ? top.sourceTitle : top.sourcePublisher
                )
            } else {
                state = .failed(reason: "Couldn't find an answer for the test query. The bundled pack may be missing.")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView().environmentObject(PackManager())
}
