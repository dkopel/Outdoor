import SwiftUI

/// Renders a single message in the chat scroll view. Different layouts for
/// user vs assistant; assistant answers expand into a card with cited chunks.
struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        switch message.role {
        case .user:
            userBubble
        case .assistant:
            assistantBubble
        }
    }

    private var userBubble: some View {
        HStack {
            Spacer(minLength: 32)
            Text(message.text)
                .font(OType.body)
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, OSpace.m)
                .padding(.vertical, OSpace.s)
                .background(OColor.spruce, in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
        }
        .padding(.horizontal, OSpace.m)
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }

    @ViewBuilder
    private var assistantBubble: some View {
        switch message.kind {
        case .assistantAnswer(let chunks, let decision):
            answerCard(chunks: chunks, decision: decision)
        case .refusal(let decision):
            refusalCard(decision: decision)
        case .emptyResult:
            informationCard(text: message.text, icon: "questionmark.bubble.fill", tint: OColor.textSecondary)
        case .userQuery:
            EmptyView()
        }
    }

    private func answerCard(chunks: [RetrievedChunk], decision: RouteDecision) -> some View {
        VStack(alignment: .leading, spacing: OSpace.s) {
            // Optional mode header for locked / safety-appendix answers
            modeHeader(for: decision)

            // Framing paragraph
            Text(message.text)
                .font(OType.body)
                .foregroundStyle(OColor.text)
                .fixedSize(horizontal: false, vertical: true)

            // The retrieved excerpt(s)
            VStack(spacing: OSpace.s) {
                ForEach(Array(chunks.enumerated()), id: \.element.id) { _, ch in
                    chunkExcerpt(ch)
                }
            }
            .padding(.top, 2)

            // Must-include safety lines, if any
            if !decision.mustInclude.isEmpty {
                safetyAppendix(decision.mustInclude)
                    .padding(.top, OSpace.xs)
            }
        }
        .padding(OSpace.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(OColor.surface, in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                .strokeBorder(OColor.separator, lineWidth: 0.5)
        )
        .padding(.horizontal, OSpace.m)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func refusalCard(decision: RouteDecision) -> some View {
        VStack(alignment: .leading, spacing: OSpace.s) {
            HStack(spacing: OSpace.xs) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(OColor.hazardCritical)
                Text("Safety: this question is off-limits")
                    .font(OType.labelM)
                    .foregroundStyle(OColor.hazardCritical)
            }
            Text(message.text)
                .font(OType.body)
                .foregroundStyle(OColor.text)
                .fixedSize(horizontal: false, vertical: true)
            if !decision.mustInclude.isEmpty {
                safetyAppendix(decision.mustInclude)
                    .padding(.top, OSpace.xs)
            }
        }
        .padding(OSpace.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            OColor.hazardCritical.opacity(0.06),
            in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                .strokeBorder(OColor.hazardCritical.opacity(0.25), lineWidth: 1)
        )
        .padding(.horizontal, OSpace.m)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func informationCard(text: String, icon: String, tint: Color) -> some View {
        HStack(alignment: .top, spacing: OSpace.s) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
            Text(text)
                .font(OType.body)
                .foregroundStyle(OColor.text)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(OSpace.m)
        .background(OColor.surface, in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                .strokeBorder(OColor.separator, lineWidth: 0.5)
        )
        .padding(.horizontal, OSpace.m)
    }

    @ViewBuilder
    private func modeHeader(for decision: RouteDecision) -> some View {
        if decision.answerMode == "locked_procedure" {
            HStack(spacing: 6) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 12, weight: .semibold))
                Text("Locked procedure")
                    .font(OType.labelS)
            }
            .foregroundStyle(OColor.hazardHigh)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(OColor.hazardHigh.opacity(0.12), in: Capsule())
        } else if decision.answerMode == "rag_with_safety_appendix" {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 12, weight: .semibold))
                Text("Read the safety notes")
                    .font(OType.labelS)
            }
            .foregroundStyle(OColor.hazardMedium)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(OColor.hazardMedium.opacity(0.14), in: Capsule())
        }
    }

    private func chunkExcerpt(_ rc: RetrievedChunk) -> some View {
        let c = rc.chunk
        return VStack(alignment: .leading, spacing: OSpace.xs) {
            HStack(spacing: OSpace.xs) {
                DomainIcon(domain: c.domain, size: 22)
                Text(c.sectionTitle)
                    .font(OType.h3)
                    .foregroundStyle(OColor.text)
                Spacer(minLength: 0)
                if c.hazardLevel == "high" || c.hazardLevel == "critical" {
                    HazardBadge(level: c.hazardLevel)
                }
            }
            Text(c.text)
                .font(OType.body)
                .foregroundStyle(OColor.text)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
            HStack {
                CitationChip(chunk: rc)
                Spacer(minLength: 0)
            }
            .padding(.top, 2)
        }
        .padding(OSpace.s)
        .background(OColor.surfaceMuted, in: RoundedRectangle(cornerRadius: ORadius.button, style: .continuous))
    }

    private func safetyAppendix(_ lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(lines, id: \.self) { line in
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(OColor.hazardMedium)
                        .padding(.top, 3)
                    Text(line)
                        .font(OType.bodySmall)
                        .foregroundStyle(OColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(OSpace.s)
        .background(OColor.hazardMedium.opacity(0.08), in: RoundedRectangle(cornerRadius: ORadius.button, style: .continuous))
    }
}
