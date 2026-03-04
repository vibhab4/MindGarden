import SwiftUI

// Background: yellowish orange #FFAB0F with soft gradient
private extension Color {
    static let appBackgroundAccent = Color(red: 1, green: 171/255, blue: 15/255)
    static let appBackgroundLight = Color(red: 1, green: 200/255, blue: 120/255) // softer, lighter
    static let homeText = Color(red: 122/255, green: 125/255, blue: 90/255)      // #7A7D5A
    /// Darker green for MindGarden title on CBT page (contrast on beige).
    static let homeTitle = Color(red: 85/255, green: 100/255, blue: 72/255)
    /// Lighter green for MindGarden title on homepage only.
    static let homeTitleLight = Color(red: 165/255, green: 180/255, blue: 155/255)
    static let oliveAccent = Color(red: 122/255, green: 125/255, blue: 90/255)   // same tone for buttons
}

// MARK: - Loading screen (splash)

struct CuteDuck: View {
    var size: CGFloat = 120
    @State private var bob = false
    @State private var blink = false
    private let outline = Color(red: 0.36, green: 0.20, blue: 0.10)

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.95, blue: 0.55),
                            Color(red: 1.0, green: 0.85, blue: 0.35)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size, height: size)
                .overlay(Circle().stroke(outline, lineWidth: size * 0.08))

            Circle()
                .fill(Color.pink.opacity(0.25))
                .frame(width: size * 0.22, height: size * 0.18)
                .offset(x: -size * 0.28, y: size * 0.05)
            Circle()
                .fill(Color.pink.opacity(0.25))
                .frame(width: size * 0.22, height: size * 0.18)
                .offset(x: size * 0.28, y: size * 0.05)

            HStack(spacing: size * 0.35) {
                Group {
                    if blink {
                        RoundedRectangle(cornerRadius: 2).fill(outline).frame(width: size * 0.10, height: size * 0.03)
                    } else {
                        Circle().fill(outline).frame(width: size * 0.10, height: size * 0.10)
                    }
                    if blink {
                        RoundedRectangle(cornerRadius: 2).fill(outline).frame(width: size * 0.10, height: size * 0.03)
                    } else {
                        Circle().fill(outline).frame(width: size * 0.10, height: size * 0.10)
                    }
                }
            }
            .offset(y: -size * 0.05)

            RoundedRectangle(cornerRadius: size * 0.08)
                .fill(Color.orange)
                .frame(width: size * 0.22, height: size * 0.18)
                .overlay(RoundedRectangle(cornerRadius: size * 0.08).stroke(outline, lineWidth: size * 0.05))
                .offset(y: size * 0.05)

            Circle().fill(outline).frame(width: size * 0.12, height: size * 0.08).offset(x: -size * 0.18, y: size * 0.55)
            Circle().fill(outline).frame(width: size * 0.12, height: size * 0.08).offset(x: size * 0.18, y: size * 0.55)
        }
        .offset(y: bob ? -8 : 8)
        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: bob)
        .onAppear {
            bob = true
            startBlinking()
        }
    }

    private func startBlinking() {
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.1)) { blink = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.1)) { blink = false }
            }
        }
    }
}

struct LoadingView_VectorDuck: View {
    @State private var progress: CGFloat = 0.0
    @State private var isComplete = false
    @State private var hasCalledComplete = false
    /// Total time for the bar to visually fill.
    /// Slightly shorter than the total splash time so it finishes before transition.
    let fillDuration: TimeInterval = 1.2
    /// Hold at 100% before transitioning (bar is full during this time).
    let holdDuration: TimeInterval = 0.8
    var onComplete: (() -> Void)?

    var body: some View {
        ZStack {
            Color(red: 227/255, green: 201/255, blue: 164/255)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer()
                CuteDuck(size: 120)
                    .scaleEffect(isComplete ? 1.08 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.65), value: isComplete)
                    .shadow(color: .black.opacity(0.14), radius: 18, y: 12)

                Text("Preparing your MindGarden!")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.top, 24)

                // Progress bar that always fills the available width
                GeometryReader { geo in
                    let trackWidth = geo.size.width - 40 // account for horizontal padding
                    
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 16)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(6, trackWidth * progress), height: 16)
                            .animation(.linear(duration: 0.1), value: progress)
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 16)
                .padding(.top, 8)
                .padding(.bottom, 30)
                Spacer()
            }
            .padding()
        }
        .onAppear {
            guard !hasCalledComplete else { return }
            
            // Smoothly fill the bar over fillDuration
            withAnimation(.linear(duration: fillDuration)) {
                progress = 1.0
            }
            
            // After the bar is full, trigger the duck "complete" state and then transition
            DispatchQueue.main.asyncAfter(deadline: .now() + fillDuration) {
                isComplete = true
                #if os(iOS)
                let gen = UINotificationFeedbackGenerator()
                gen.notificationOccurred(.success)
                #endif
                
                DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
                    guard !hasCalledComplete else { return }
                    hasCalledComplete = true
                    onComplete?()
                }
            }
        }
    }
}

// MARK: - Guide Duck (SwiftUI-only, 0 images)

struct GuideDuckWithSpeech: View {
    var message: String
    /// Controls whether the duck gently bounces. Turn off for a calmer, anchored duck.
    var enableBounce: Bool = true
    
    @State private var bounce = false
    @State private var blink = false
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // Speech bubble (left of duck)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                        )
                )
                .padding(.trailing, 4)
            
            // Vector duck from loading screen, reused as the assistant avatar
            CuteDuck(size: 72)
                .scaleEffect(enableBounce && bounce ? 1.05 : 1.0)
                .animation(
                    .easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                    value: bounce
                )
                .onAppear {
                    if enableBounce {
                        bounce = true
                    }
                    startBlinking()
                }
        }
        .padding(.trailing, 16)
        .padding(.bottom, 24)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Guide duck says: \(message)")
    }
    
    private func startBlinking() {
        Timer.scheduledTimer(withTimeInterval: 2.8, repeats: true) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.12)) { blink = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    withAnimation(.easeInOut(duration: 0.12)) { blink = false }
                }
            }
        }
    }
}

private struct GuideDuck: View {
    @Binding var bounce: Bool
    @Binding var blink: Bool
    
    var body: some View {
        ZStack {
            // Soft glow
            Circle()
                .fill(
                    RadialGradient(colors: [
                        Color.yellow.opacity(0.35),
                        Color.orange.opacity(0.15),
                        Color.clear
                    ], center: .center, startRadius: 8, endRadius: 44)
                )
                .frame(width: 88, height: 88)
                .blur(radius: 3)
            
            // Body (round duck belly)
            Circle()
                .fill(
                    LinearGradient(colors: [
                        Color(white: 0.98),
                        Color(white: 0.92)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 52, height: 52)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.5), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            
            // Wing (small ellipse on side)
            Ellipse()
                .fill(
                    LinearGradient(colors: [
                        Color(white: 0.92),
                        Color(white: 0.88)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 22, height: 28)
                .overlay(Ellipse().stroke(.white.opacity(0.3), lineWidth: 1))
                .offset(x: 14, y: 2)
            
            // Beak (flat duck bill)
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(
                    LinearGradient(colors: [
                        Color.orange,
                        Color.orange.opacity(0.85)
                    ], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 18, height: 10)
                .offset(x: 18, y: 4)
            
            // Eyes
            HStack(spacing: 14) {
                GuideEye(isBlinking: blink)
                GuideEye(isBlinking: blink)
            }
            .offset(x: -4, y: -6)
        }
        .offset(y: bounce ? -4 : 0)
        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: bounce)
    }
}

private struct GuideEye: View {
    let isBlinking: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(Color.primary.opacity(0.7))
            .frame(width: 6, height: isBlinking ? 1.5 : 6)
            .animation(.easeInOut(duration: 0.12), value: isBlinking)
    }
}

// MARK: - Homepage

struct HomePageView: View {
    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Match loading screen background (#E3C9A4) but with subtle depth
                LinearGradient(
                    colors: [
                        Color(red: 227/255, green: 201/255, blue: 164/255),
                        Color(red: 227/255, green: 201/255, blue: 164/255).opacity(0.92)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Soft glow behind hero section
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.35),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 260
                        )
                    )
                    .blur(radius: 20)
                    .offset(y: -260)
                
                VStack(spacing: 28) {
                    // Vertically center hero + grid, while keeping a bit of top breathing room
                    Spacer(minLength: 40)

                    HomeHeroCard()

                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        HomePageButton(
                            title: "CBT",
                            icon: "brain.head.profile",
                            color: .blue,
                            destination: {
                                ContentView()
                            }
                        )
                        
                        HomePageButton(
                            title: "Breathe",
                            icon: "wind",
                            color: .mint,
                            destination: {
                                JustBreathe()
                            }
                        )
                        
                        HomePageButton(
                            title: "Daily Journal",
                            icon: "book.fill",
                            color: .purple,
                            destination: {
                                JournalView()
                            }
                        )
                        
                        HomePageButton(
                            title: "Progress",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .orange,
                            destination: {
                                InsightsView()
                            }
                        )
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    Text("Offline • Private • Designed for quick resets")
                        .font(.footnote)
                        .foregroundStyle(Color.homeText.opacity(0.8))
                        .padding(.bottom)
                }
                
                // Calmer, anchored duck on the home screen (no vertical bounce),
                // aligned to the bottom-right of the full screen.
                GuideDuckWithSpeech(
                    message: "Welcome back! How are you doing today?",
                    enableBounce: false
                )
            }
        }
    }
}

struct HomePageButton<Destination: View>: View {
    let title: String
    let icon: String
    let color: Color
    let destination: () -> Destination
    
    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    // keep the original colorful symbol tint
                    .foregroundStyle(color)
                    .frame(width: 52, height: 52)
                    .background(Color.white.opacity(0.14))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    )
                
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.black)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [
                        Color.oliveAccent,
                        Color.oliveAccent.opacity(0.84)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                LinearGradient(
                    colors: [.white.opacity(0.18), .clear],
                    startPoint: .top,
                    endPoint: .center
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
            )
            .shadow(color: Color.oliveAccent.opacity(0.28), radius: 16, y: 10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Journal View

struct JournalView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("journalEntries") private var journalEntriesData: Data = Data()
    @State private var entries: [JournalEntry] = []
    @State private var showingNewEntry = false
    @State private var newEntryText = ""
    @State private var newEntryDate = Date()
    
    struct JournalEntry: Codable, Identifiable {
        let id: UUID
        let text: String
        let date: Date
    }
    
    private var journalBackground: LinearGradient {
        // Match Breathe page background (#334D42 → darker)
        let base = Color(red: 51/255, green: 77/255, blue: 66/255)
        let darker = Color(red: 28/255, green: 42/255, blue: 36/255)
        return LinearGradient(
            colors: [base, darker],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                journalBackground
                    .ignoresSafeArea()
                
                VStack {
                    if entries.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            Text("No entries yet")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            Text("Start writing to track your thoughts")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(entries) { entry in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(entry.text)
                                        .font(.body)
                                    Text(entry.date, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                            .onDelete(perform: deleteEntries)
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Daily Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewEntry = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                NavigationStack {
                    VStack(spacing: 16) {
                        TextEditor(text: $newEntryText)
                            .frame(minHeight: 200)
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Button {
                            let entry = JournalEntry(id: UUID(), text: newEntryText, date: Date())
                            entries.insert(entry, at: 0)
                            saveEntries()
                            newEntryText = ""
                            showingNewEntry = false
                        } label: {
                            Text("Save Entry")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newEntryText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding()
                    .navigationTitle("New Entry")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                newEntryText = ""
                                showingNewEntry = false
                            }
                        }
                    }
                }
            }
            .onAppear {
                loadEntries()
            }
        }
    }
    
    private func loadEntries() {
        if let decoded = try? JSONDecoder().decode([JournalEntry].self, from: journalEntriesData) {
            entries = decoded.sorted(by: { $0.date > $1.date })
        }
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            journalEntriesData = encoded
        }
    }
    
    private func deleteEntries(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        saveEntries()
    }
}

// MARK: - Insights View

struct InsightsView: View {
    @AppStorage("growthPoints") private var growthPoints: Int = 0
    @AppStorage("sessionsCompleted") private var sessionsCompleted: Int = 0
    @AppStorage("journalEntries") private var journalEntriesData: Data = Data()
    
    private var insightsBackground: LinearGradient {
        let base = Color(red: 51/255, green: 77/255, blue: 66/255)
        let darker = Color(red: 28/255, green: 42/255, blue: 36/255)
        return LinearGradient(
            colors: [base, darker],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var journalEntryCount: Int {
        if let entries = try? JSONDecoder().decode([JournalView.JournalEntry].self, from: journalEntriesData) {
            return entries.count
        }
        return 0
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                insightsBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text("Your Progress")
                            .font(.title.bold())
                        Text("Track your growth journey")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)
                    
                    VStack(spacing: 16) {
                        InsightCard(
                            title: "Total Sessions",
                            value: "\(sessionsCompleted)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        InsightCard(
                            title: "Growth Points",
                            value: "\(growthPoints)",
                            icon: "sparkles",
                            color: .yellow
                        )
                        
                        InsightCard(
                            title: "Journal Entries",
                            value: "\(journalEntryCount)",
                            icon: "book.fill",
                            color: .purple
                        )
                        
                        InsightCard(
                            title: "Current Stage",
                            value: PlantStages.label(for: PlantStages.stage(for: growthPoints)),
                            icon: PlantStages.symbol(for: PlantStages.stage(for: growthPoints)),
                            color: .blue
                        )
                    }
                    .padding(.horizontal)
                    
                    if sessionsCompleted > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Activity Summary")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Text("You've completed \(sessionsCompleted) session\(sessionsCompleted == 1 ? "" : "s") and earned \(growthPoints) growth point\(growthPoints == 1 ? "" : "s"). Keep up the great work!")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom)
                }
                }
            }
            .navigationTitle("Insights")
            .preferredColorScheme(.dark)
        }
    
}

struct InsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 50, height: 50)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title3.bold())
            }
            
            Spacer()
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(.white.opacity(0.12))
        )
    }
}

// MARK: - Original Content View (CBT Methods)

enum Module: String, CaseIterable, Identifiable {
    case ground = "Ground"
    case reframe = "Reframe"
    case act = "Act"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .ground: return "wave.3.right"
        case .reframe: return "arrow.triangle.2.circlepath"
        case .act: return "figure.walk"
        }
    }
    
    var subtitle: String {
        switch self {
        case .ground: return "5-4-3-2-1 reset"
        case .reframe: return "thought → balanced thought"
        case .act: return "one tiny next step"
        }
    }
}

struct ContentView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("growthPoints") private var growthPoints: Int = 0
    @AppStorage("sessionsCompleted") private var sessionsCompleted: Int = 0
    @State private var shouldPopToHomeAfterGround = false
    
    var plantStage: Int {
        PlantStages.stage(for: growthPoints)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Match homepage background (warm beige gradient)
                LinearGradient(
                    colors: [
                        Color(red: 227/255, green: 201/255, blue: 164/255),
                        Color(red: 227/255, green: 201/255, blue: 164/255).opacity(0.92)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    VStack(spacing: 6) {
                        Text("MindGarden")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color.homeTitle)
                        Text("Grow calm, clarity, and action.")
                            .font(.subheadline)
                            .foregroundStyle(Color.homeText.opacity(0.85))
                    }
                    
                    PlantCard(stage: plantStage,
                              growthPoints: growthPoints,
                              sessions: sessionsCompleted)
                    
                    VStack(spacing: 14) {
                        Text("Practices")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        NavigationLink {
                            GroundFlowView(onFinish: {
                                growthPoints += 1
                                sessionsCompleted += 1
                                shouldPopToHomeAfterGround = true
                            }, autoStartMode: .gentle)
                        } label: {
                            ModuleCard(
                                module: .ground,
                                overrideTitle: "Gentle Reset",
                                overrideSubtitle: "5-4-3-2-1 senses"
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink {
                            GroundFlowView(onFinish: {
                                growthPoints += 1
                                sessionsCompleted += 1
                                shouldPopToHomeAfterGround = true
                            }, autoStartMode: .explore)
                        } label: {
                            ModuleCard(
                                module: .ground,
                                overrideTitle: "Explore Your Senses",
                                overrideSubtitle: "Playful sensory prompts"
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink {
                            ReframeView(onComplete: { })
                        } label: {
                            ModuleCard(module: .reframe)
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink {
                            ActView(onComplete: { shouldPopToHomeAfterGround = true })
                        } label: {
                            ModuleCard(module: .act)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    Text("Take it one moment at a time.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .overlay(alignment: .bottomTrailing) {
                    GuideDuckWithSpeech(message: "Pick a practice when you're ready. You've got this!")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                }
            }
        }
        .onChange(of: shouldPopToHomeAfterGround) { shouldPop in
            if shouldPop {
                shouldPopToHomeAfterGround = false
                dismiss()
            }
        }
    }
}

// MARK: - Reframe (automatic thought → suggested balanced thoughts → Save & Done)

struct ReframeView: View {
    var onComplete: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("growthPoints") private var growthPoints: Int = 0
    @AppStorage("sessionsCompleted") private var sessionsCompleted: Int = 0
    @State private var thought: String = ""
    @State private var balanced: String = ""
    
    /// Computed from thought so typing doesn't trigger state updates and steal focus from TextField.
    private var suggestions: [String] { makeSuggestions(from: thought) }
    
    private var reframeGradient: LinearGradient {
        let base = Color(red: 51/255, green: 77/255, blue: 66/255)
        let darker = Color(red: 28/255, green: 42/255, blue: 36/255)
        return LinearGradient(
            colors: [base, darker],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            reframeGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 18) {
                    Text("Name the thought that's bothering you. Then choose a helpful way to reframe it.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Automatic thought")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                        TextField("e.g., I messed up and will fail everything", text: $thought)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)
                    
                    if !thought.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Suggested ways to reframe")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(suggestions, id: \.self) { s in
                                    Button {
                                        balanced = s
                                    } label: {
                                        Text(s)
                                            .font(.caption)
                                            .foregroundStyle(.primary)
                                            .multilineTextAlignment(.leading)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 10)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(.ultraThinMaterial)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12)))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Balanced thought")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                        TextField("A more balanced version…", text: $balanced)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)
                    
                    Button {
                        growthPoints += 1
                        sessionsCompleted += 1
                        onComplete?()
                        dismiss()
                    } label: {
                        Text("Save & Done")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(balanced.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 24)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Reframe")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func makeSuggestions(from input: String) -> [String] {
        let base = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !base.isEmpty else {
            return [
                "I can take one next step and ask for help if I need it.",
                "This feels big now, but I can handle one small piece.",
                "Even if things are hard, I can try and learn from it."
            ]
        }
        let snippet = base.count > 40 ? String(base.prefix(40)) + "…" : base
        return [
            "What I'd tell a friend: \"Even if \(snippet), I can take one next step and ask for help.\"",
            "A balanced thought: \"I may feel \(snippet), but I can try one step and see what happens.\"",
            "If a friend said this, I'd tell them: \"It's okay — you can try one step and ask for help.\""
        ]
    }
}

// MARK: - Act (one random tiny action + "I did it" / "Another")

private let actActions = [
    "Drink a glass of water.",
    "Stand up and stretch for 20 seconds.",
    "Take 5 slow belly breaths.",
    "Step outside for 60 seconds.",
    "Write one sentence in Notes about how you feel.",
    "Text one friend: \"Thinking of you — you okay?\"",
    "Tidy one small surface.",
    "Look out the window and name three things you see.",
    "Do 10 shoulder rolls.",
    "Sit quietly for 30 seconds and notice your breath."
]

struct ActView: View {
    var onComplete: (() -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("growthPoints") private var growthPoints: Int = 0
    @AppStorage("sessionsCompleted") private var sessionsCompleted: Int = 0
    @State private var currentAction: String = ""
    
    private var actGradient: LinearGradient {
        let base = Color(red: 51/255, green: 77/255, blue: 66/255)
        let darker = Color(red: 28/255, green: 42/255, blue: 36/255)
        return LinearGradient(
            colors: [base, darker],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            actGradient
                .ignoresSafeArea()
            
            VStack(spacing: 18) {
                Text("Choose one tiny, doable step. When you're done, tap \"I did it.\"")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(currentAction)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)
                
                HStack(spacing: 12) {
                    Button {
                        growthPoints += 1
                        sessionsCompleted += 1
                        onComplete?()
                        dismiss()
                    } label: {
                        Text("I did it")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        pickAnother()
                    } label: {
                        Text("Another")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .onAppear {
            if currentAction.isEmpty { pickAnother() }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Act")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func pickAnother() {
        currentAction = actActions.randomElement() ?? "Take 3 slow breaths."
    }
}

// MARK: - UI Components

struct PlantCard: View {
    let stage: Int
    let growthPoints: Int
    let sessions: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: PlantStages.symbol(for: stage))
                .font(.system(size: 64, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .padding(.top, 6)
            
            Text(PlantStages.label(for: stage))
                .font(.headline)
            
            HStack(spacing: 12) {
                StatPill(title: "Stage", value: "\(stage)/\(PlantStages.maxStage)")
                StatPill(title: "Growth", value: "\(growthPoints)")
                StatPill(title: "Sessions", value: "\(sessions)")
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(.white.opacity(0.18))
        )
    }
}

struct StatPill: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.headline)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Home hero card

struct HomeHeroCard: View {
    @AppStorage("growthPoints") private var growthPoints: Int = 0
    @AppStorage("sessionsCompleted") private var sessionsCompleted: Int = 0
    
    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("MindGarden")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color.homeTitleLight)
                
                Text("Grow calm, clarity, and action.")
                    .font(.subheadline)
                    .foregroundStyle(Color.homeTitleLight.opacity(0.88))
                
                HStack(spacing: 12) {
                    Label("\(sessionsCompleted)", systemImage: "checkmark.circle")
                        .font(.caption)
                    Label("\(growthPoints)", systemImage: "leaf.fill")
                        .font(.caption)
                }
                .foregroundStyle(Color.homeTitleLight.opacity(0.9))
                .padding(.top, 4)
            }
            
            Spacer()
            
            CuteDuck(size: 72)
                .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.16), radius: 18, y: 10)
        .padding(.horizontal)
    }
}

struct ModuleCard: View {
    let module: Module
    var overrideTitle: String? = nil
    var overrideSubtitle: String? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: module.icon)
                .font(.title3.bold())
                .frame(width: 30)
                .symbolRenderingMode(.hierarchical)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(overrideTitle ?? module.rawValue)
                    .font(.headline)
                Text(overrideSubtitle ?? module.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.black)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(.white.opacity(0.12))
        )
    }
}

// MARK: - Ground Module (5-4-3-2-1 grounding, fully offline)

enum GroundMode: String, CaseIterable {
    case gentle = "Gentle Reset"
    case explore = "Explore Your Senses"
}

enum GroundStep: Int, CaseIterable, Identifiable {
    case see = 0
    case feel
    case hear
    case smell
    case taste
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .see: return "See"
        case .feel: return "Feel"
        case .hear: return "Hear"
        case .smell: return "Smell"
        case .taste: return "Taste"
        }
    }
    
    var targetCount: Int {
        switch self {
        case .see: return 5
        case .feel: return 4
        case .hear: return 3
        case .smell: return 2
        case .taste: return 1
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .see: return "eye"
        case .feel: return "hand.point.up.left"
        case .hear: return "ear"
        case .smell: return "nose"
        case .taste: return "mouth"
        }
    }
    
    static var ordered: [GroundStep] { [.see, .feel, .hear, .smell, .taste] }
}

struct GroundVariationSet {
    let name: String
    let prompts: [GroundStep: String]
}

private let groundGentlePrompts: [GroundStep: String] = [
    .see: "Name 5 things you can see.",
    .feel: "Name 4 things you can feel (touch or sense in your body).",
    .hear: "Name 3 things you can hear.",
    .smell: "Name 2 things you can smell. If not available, imagine a comforting smell or take a breath of fresh air.",
    .taste: "Name 1 thing you can taste. If not available, imagine a comforting taste or sip water."
]

private let groundVariationSets: [GroundVariationSet] = [
    GroundVariationSet(name: "Color Hunt", prompts: [
        .see: "Find 5 things that are blue (or any color you choose).",
        .feel: "Find 4 different textures around you—smooth, rough, soft, cool.",
        .hear: "Notice 3 sounds: one close, one far, one in between.",
        .smell: "Notice 2 scents. If none around, imagine a comforting smell or step outside for a breath.",
        .taste: "Notice 1 taste—a sip of water, gum, or imagine your favorite comfort taste."
    ]),
    GroundVariationSet(name: "Near & Far", prompts: [
        .see: "See 5 things: 3 close to you, 2 farther away.",
        .feel: "Feel 4 things: temperature, texture, pressure, or movement.",
        .hear: "Hear 3 sounds and notice where each comes from.",
        .smell: "2 smells—or imagine two calming scents if needed.",
        .taste: "1 taste. If not available, imagine a comforting taste or sip water."
    ]),
    GroundVariationSet(name: "Texture Explorer", prompts: [
        .see: "Spot 5 different surfaces or materials in the room.",
        .feel: "Touch 4 different textures with your hands or feet.",
        .hear: "Listen for 3 distinct sounds—loud, quiet, or in between.",
        .smell: "Find 2 smells nearby, or imagine two soothing scents.",
        .taste: "One taste—sip water, or imagine something comforting."
    ])
]

private let groundSwapPrompts: [GroundStep: [String]] = [
    .see: [
        "Name 5 things you can see.",
        "Find 5 things that are blue (or any color you choose).",
        "Spot 5 different surfaces or materials in the room.",
        "See 5 things: 3 close to you, 2 farther away."
    ],
    .feel: [
        "Name 4 things you can feel (touch or sense in your body).",
        "Find 4 different textures—smooth, rough, soft, cool.",
        "Feel 4 things: temperature, texture, pressure, or movement.",
        "Touch 4 different textures with your hands or feet."
    ],
    .hear: [
        "Name 3 things you can hear.",
        "Notice 3 sounds: one close, one far, one in between.",
        "Hear 3 sounds and notice where each comes from.",
        "Listen for 3 distinct sounds."
    ],
    .smell: [
        "Name 2 things you can smell. If not available, imagine a comforting smell.",
        "Notice 2 scents, or imagine two calming scents if needed.",
        "Find 2 smells nearby, or imagine two soothing scents.",
        "2 smells—or imagine two calming scents. Take a breath of fresh air if you can."
    ],
    .taste: [
        "Name 1 thing you can taste. If not available, imagine a comforting taste or sip water.",
        "Notice 1 taste—a sip of water, gum, or imagine your favorite comfort taste.",
        "One taste. If not available, imagine something comforting.",
        "1 taste. Sip water or imagine a comforting taste."
    ]
]

struct GroundFlowView: View {
    let onFinish: () -> Void
    /// If provided, skip the intro screen and immediately start in this mode.
    let autoStartMode: GroundMode?
    
    @Environment(\.dismiss) private var dismiss
    
    enum Phase: Equatable {
        case intro
        case step(GroundStep)
        case completion
    }
    
    @State private var phase: Phase = .intro
    @State private var mode: GroundMode = .gentle
    @State private var selectedVariationSet: GroundVariationSet?
    @State private var stepCounts: [GroundStep: Int] = [.see: 0, .feel: 0, .hear: 0, .smell: 0, .taste: 0]
    @State private var currentStepPrompt: String = ""
    @State private var currentStepPromptIndex: Int = 0
    @State private var didAutoStart = false
    
    /// Match Breathe page background (dark green gradient #334D42).
    private var groundGradient: LinearGradient {
        let base = Color(red: 51/255, green: 77/255, blue: 66/255)
        let darker = Color(red: 28/255, green: 42/255, blue: 36/255)
        return LinearGradient(
            colors: [base, darker],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            groundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                switch phase {
                case .intro:
                    groundIntroView
                case .step(let step):
                    groundStepView(step: step)
                case .completion:
                    groundCompletionView
                }
            }
        }
        .onAppear {
            if !didAutoStart, let modeToStart = autoStartMode {
                didAutoStart = true
                mode = modeToStart
                if modeToStart == .explore {
                    selectedVariationSet = groundVariationSets.randomElement()
                    currentStepPromptIndex = 0
                }
                startGroundFlow()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: phase)
    }
    
    private var groundIntroView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Ground")
                    .font(.largeTitle.bold())
                    .padding(.top, 24)
                
                Text("Choose how you'd like to ground today:")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    Button {
                        mode = .gentle
                        startGroundFlow()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.title2)
                            Text("Gentle Reset")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.black)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        mode = .explore
                        selectedVariationSet = groundVariationSets.randomElement()
                        currentStepPromptIndex = 0
                        startGroundFlow()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "leaf.fill")
                                .font(.title2)
                            Text("Explore Your Senses")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.black)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                
                Text("No pressure. Skip anything that doesn't fit your environment.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                
                Spacer(minLength: 40)
            }
        }
    }
    
    private func startGroundFlow() {
        stepCounts = [.see: 0, .feel: 0, .hear: 0, .smell: 0, .taste: 0]
        if let first = GroundStep.ordered.first {
            setGroundPromptForStep(first)
            phase = .step(first)
        }
    }
    
    private func setGroundPromptForStep(_ step: GroundStep) {
        currentStepPromptIndex = 0
        switch mode {
        case .gentle:
            currentStepPrompt = groundGentlePrompts[step] ?? ""
        case .explore:
            if let set = selectedVariationSet, let p = set.prompts[step] {
                currentStepPrompt = p
            } else {
                currentStepPrompt = groundGentlePrompts[step] ?? ""
            }
        }
    }
    
    private func swapGroundPromptForStep(_ step: GroundStep) {
        guard let options = groundSwapPrompts[step], options.count > 1 else { return }
        currentStepPromptIndex = (currentStepPromptIndex + 1) % options.count
        currentStepPrompt = options[currentStepPromptIndex]
    }
    
    private func groundStepView(step: GroundStep) -> some View {
        let count = stepCounts[step] ?? 0
        let target = step.targetCount
        let canNext = count >= target
        
        return ScrollView {
            VStack(spacing: 24) {
                Text("\(target)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.top, 20)
                
                HStack(spacing: 8) {
                    Image(systemName: step.sfSymbol)
                        .font(.title2)
                    Text(step.title)
                        .font(.title2.bold())
                }
                .foregroundStyle(.primary)
                
                Text(currentStepPrompt)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                if mode == .explore {
                    Button {
                        swapGroundPromptForStep(step)
                    } label: {
                        Label("Try a different prompt", systemImage: "arrow.triangle.2.circlepath")
                            .font(.subheadline)
                    }
                    .buttonStyle(.bordered)
                }
                
                Text("\(count)/\(target)")
                    .font(.title.bold())
                    .padding(.vertical, 8)
                
                HStack(spacing: 16) {
                    Button {
                        if (stepCounts[step] ?? 0) > 0 {
                            stepCounts[step] = (stepCounts[step] ?? 0) - 1
                        }
                    } label: {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                            .font(.subheadline)
                    }
                    .buttonStyle(.bordered)
                    .disabled((stepCounts[step] ?? 0) == 0)
                    
                    Button {
                        stepCounts[step] = min((stepCounts[step] ?? 0) + 1, target)
#if os(iOS)
                        let gen = UIImpactFeedbackGenerator(style: .light)
                        gen.impactOccurred()
#endif
                    } label: {
                        Label("+1 Found", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal, 20)
                
                Button {
                    goToNextGroundStep(step)
                } label: {
                    Text("Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canNext)
                .padding(.horizontal, 20)
                
                Button {
                    goToNextGroundStep(step)
                } label: {
                    Text("Skip this step")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
                
                Spacer(minLength: 40)
            }
        }
        .padding(.top, 8)
    }
    
    private func goToNextGroundStep(_ step: GroundStep) {
        let order = GroundStep.ordered
        guard let idx = order.firstIndex(of: step), idx + 1 < order.count else {
            phase = .completion
            return
        }
        let next = order[idx + 1]
        setGroundPromptForStep(next)
        phase = .step(next)
    }
    
    private var groundCompletionView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.9))
            
            Text("Nice work.")
                .font(.title.bold())
            
            Text("You've grounded yourself using your senses. Take this calm with you.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Text("Mode: \(mode.rawValue)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Button {
#if os(iOS)
                let gen = UINotificationFeedbackGenerator()
                gen.notificationOccurred(.success)
#endif
                onFinish()
                dismiss()
            } label: {
                Text("Finish")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            Spacer()
        }
    }
}

// MARK: - Module Flow

struct ModuleFlowView: View {
    let module: Module
    let onComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    // simple mood slider (before/after)
    @State private var beforeIntensity: Double = 7
    @State private var afterIntensity: Double = 5
    
    var body: some View {
        Group {
            if module == .ground {
                GroundFlowView(onFinish: {
                    onComplete()
                    dismiss()
                }, autoStartMode: nil)
            } else {
                groundOrOtherModuleContent
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if module != .ground {
                GuideDuckWithSpeech(message: "Take your time. You're doing great.")
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, 4)
    }
    
    private var groundOrOtherModuleContent: some View {
        VStack(spacing: 16) {
            Text(module.rawValue)
                .font(.largeTitle.bold())
                .padding(.top, 8)
            
            Text(helperText)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Group {
                switch module {
                case .ground:
                    EmptyView()
                case .reframe:
                    ReframePlaceholder()
                case .act:
                    ActPlaceholder()
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Intensity (before)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $beforeIntensity, in: 0...10, step: 1)
                
                Text("Intensity (after)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $afterIntensity, in: 0...10, step: 1)
            }
            .padding(.horizontal)
            
            Button {
                onComplete()
#if os(iOS)
                let gen = UINotificationFeedbackGenerator()
                gen.notificationOccurred(.success)
#endif
                dismiss()
            } label: {
                Text("Complete → Grow the garden")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.top, 6)
            
            Spacer()
        }
    }
    
    private var helperText: String {
        switch module {
        case .ground: return "Return to the present using your senses."
        case .reframe: return "Turn an unhelpful thought into a balanced one."
        case .act: return "Choose one tiny next step."
        }
    }
}

// MARK: - Placeholders (replace these tomorrow)

struct GroundPlaceholder: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("5-4-3-2-1")
                .font(.headline)
            Text("Tomorrow we’ll turn this into a step-by-step flow.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct ReframePlaceholder: View {
    @State private var thought: String = ""
    @State private var balanced: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Automatic thought")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("e.g., I’m going to fail.", text: $thought)
                .textFieldStyle(.roundedBorder)
            
            Text("Balanced thought")
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("e.g., I can take one step and ask for help.", text: $balanced)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct ActPlaceholder: View {
    private let actions = [
        "Drink water.",
        "Stand up and stretch for 20 seconds.",
        "Write one sentence in Notes.",
        "Step outside for 1 minute.",
        "Tidy one small surface.",
        "Message a friend: “Hey, got a minute?”"
    ]
    @State private var picked: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Tiny next step")
                .font(.headline)
            
            Text(picked.isEmpty ? "Tap to pick one." : picked)
                .multilineTextAlignment(.center)
                .font(.subheadline)
            
            Button {
                picked = actions.randomElement() ?? "Take 3 slow breaths."
            } label: {
                Text(picked.isEmpty ? "Pick one" : "Pick another")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Plant stages

enum PlantStages {
    static let maxStage = 6
    
    static func stage(for points: Int) -> Int {
        // every 2 points = next stage (tweak as you like)
        min(points / 2, maxStage)
    }
    
    static func symbol(for stage: Int) -> String {
        switch stage {
        case 0: return "circle.fill"      // seed
        case 1: return "sparkles"         // first growth
        case 2: return "leaf"             // sprout
        case 3: return "leaf.fill"        // stronger
        case 4: return "tree"             // growing
        case 5: return "tree.fill"        // thriving
        case 6: return "camera.macro"     // bloom-ish (swap later)
        default: return "tree.fill"
        }
    }
    
    static func label(for stage: Int) -> String {
        switch stage {
        case 0: return "Seed"
        case 1: return "Awakening"
        case 2: return "Sprout"
        case 3: return "Growth"
        case 4: return "Rooted"
        case 5: return "Thriving"
        case 6: return "Blooming"
        default: return "Thriving"
        }
    }
}
