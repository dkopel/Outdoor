import SwiftUI

struct ChatView: View {
    @EnvironmentObject var packManager: PackManager

    var body: some View {
        // Wrapper pattern so the @StateObject inside ChatContentView is
        // initialized with the real environment-supplied PackManager.
        ChatContentView(packManager: packManager)
    }
}

private struct ChatContentView: View {
    @ObservedObject var packManager: PackManager
    @StateObject private var vm: ChatViewModel
    @FocusState private var inputFocused: Bool

    init(packManager: PackManager) {
        self.packManager = packManager
        _vm = StateObject(wrappedValue: ChatViewModel(packManager: packManager))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                content

                inputBar
                    .background(.ultraThinMaterial)
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(OColor.separator)
                            .frame(height: 0.5)
                    }
            }
            .background(OColor.background.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !vm.messages.isEmpty {
                        Button {
                            withAnimation(OMotion.soft) { vm.clear() }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        .foregroundStyle(OColor.textSecondary)
                    }
                }
            }
        }
        .onAppear {
            // Rebind to the real environment-supplied PackManager.
            vm.objectWillChange.send()
        }
    }

    private var title: String {
        if let pack = packManager.activePack {
            return pack.manifest.displayName
        }
        return "Outdoor"
    }

    @ViewBuilder
    private var content: some View {
        if vm.messages.isEmpty {
            emptyState
        } else {
            messagesList
        }
    }

    private var emptyState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: OSpace.xl) {
                hero

                VStack(alignment: .leading, spacing: OSpace.s) {
                    Text("Try asking")
                        .font(OType.labelM)
                        .foregroundStyle(OColor.textSecondary)
                        .padding(.horizontal, OSpace.m)
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: OSpace.s), GridItem(.flexible(), spacing: OSpace.s)],
                              spacing: OSpace.s) {
                        ForEach(starterPrompts, id: \.self) { p in
                            Button {
                                withAnimation(OMotion.soft) {
                                    vm.send(prompt: p)
                                }
                                inputFocused = false
                            } label: {
                                Text(p)
                                    .font(OType.bodySmall)
                                    .foregroundStyle(OColor.text)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(OSpace.s)
                                    .background(OColor.surface, in: RoundedRectangle(cornerRadius: ORadius.button, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ORadius.button, style: .continuous)
                                            .strokeBorder(OColor.separator, lineWidth: 0.5)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, OSpace.m)
                }

                packStatusCard
                    .padding(.horizontal, OSpace.m)

                Spacer(minLength: 120) // room for input bar
            }
            .padding(.top, OSpace.s)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: OSpace.s) {
            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: [
                        OColor.spruce.opacity(0.18),
                        OColor.ember.opacity(0.10),
                        OColor.background
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
                .padding(.horizontal, OSpace.m)

                VStack(alignment: .leading, spacing: OSpace.xs) {
                    HStack(spacing: OSpace.xs) {
                        Image(systemName: "mountain.2.fill")
                            .font(.system(size: 16, weight: .bold))
                        Text("Offline guide")
                            .font(OType.labelS)
                    }
                    .foregroundStyle(OColor.textSecondary)

                    Text("Ask anything\nfrom your pack.")
                        .font(OType.displayL)
                        .foregroundStyle(OColor.text)
                        .lineSpacing(2)
                    Text("No signal needed. Answers come from the curated camping pack — with sources you can verify.")
                        .font(OType.body)
                        .foregroundStyle(OColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(OSpace.l)
            }
        }
    }

    private var packStatusCard: some View {
        HStack(spacing: OSpace.s) {
            ZStack {
                Circle()
                    .fill(OColor.spruce.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(OColor.spruce)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(packManager.activePack?.manifest.displayName ?? "No pack loaded")
                    .font(OType.labelL)
                    .foregroundStyle(OColor.text)
                if let m = packManager.activePack?.manifest {
                    Text("v\(m.version) · \(m.chunkCount) chunks · works offline")
                        .font(OType.caption)
                        .foregroundStyle(OColor.textSecondary)
                }
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

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: OSpace.s) {
                    ForEach(vm.messages) { message in
                        MessageBubble(message: message)
                            .id(message.id)
                    }
                    if vm.isThinking {
                        thinkingIndicator
                            .padding(.horizontal, OSpace.m)
                            .transition(.opacity)
                    }
                    Color.clear.frame(height: 120) // input bar clearance
                        .id("BOTTOM")
                }
                .padding(.vertical, OSpace.m)
            }
            .onChange(of: vm.messages.count) {
                withAnimation(OMotion.soft) {
                    proxy.scrollTo("BOTTOM", anchor: .bottom)
                }
            }
            .onChange(of: vm.isThinking) {
                if vm.isThinking {
                    withAnimation(OMotion.soft) {
                        proxy.scrollTo("BOTTOM", anchor: .bottom)
                    }
                }
            }
        }
    }

    private var thinkingIndicator: some View {
        HStack(spacing: OSpace.xs) {
            ThinkingDots()
            Text("Searching your pack")
                .font(OType.labelM)
                .foregroundStyle(OColor.textSecondary)
            Spacer(minLength: 0)
        }
        .padding(OSpace.m)
        .background(OColor.surface, in: RoundedRectangle(cornerRadius: ORadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ORadius.card, style: .continuous)
                .strokeBorder(OColor.separator, lineWidth: 0.5)
        )
    }

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: OSpace.s) {
            ZStack(alignment: .leading) {
                if vm.input.isEmpty {
                    Text("Ask about camping…")
                        .font(OType.body)
                        .foregroundStyle(OColor.textTertiary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .allowsHitTesting(false)
                }
                TextField("", text: $vm.input, axis: .vertical)
                    .font(OType.body)
                    .foregroundStyle(OColor.text)
                    .focused($inputFocused)
                    .lineLimit(1...4)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .submitLabel(.send)
                    .onSubmit { sendNow() }
            }
            .background(OColor.surface, in: RoundedRectangle(cornerRadius: ORadius.button, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ORadius.button, style: .continuous)
                    .strokeBorder(inputFocused ? OColor.ember.opacity(0.45) : OColor.separator, lineWidth: 1)
            )

            Button {
                sendNow()
            } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle().fill(vm.canSend ? OColor.ember : OColor.textTertiary)
                    )
            }
            .disabled(!vm.canSend)
            .animation(OMotion.snappy, value: vm.canSend)
        }
        .padding(.horizontal, OSpace.m)
        .padding(.top, OSpace.s)
        .padding(.bottom, OSpace.s)
    }

    private func sendNow() {
        guard vm.canSend else { return }
        withAnimation(OMotion.soft) { vm.send() }
    }
}

private struct ThinkingDots: View {
    @State private var phase: Double = 0
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(OColor.ember)
                    .frame(width: 6, height: 6)
                    .opacity(opacity(for: i))
            }
        }
        .frame(height: 16)
        .onAppear {
            withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
    private func opacity(for i: Int) -> Double {
        let p = (phase * 3 - Double(i)).truncatingRemainder(dividingBy: 3)
        return max(0.25, 1.0 - abs(p - 1.0))
    }
}

#Preview {
    ChatView()
        .environmentObject(PackManager())
}
