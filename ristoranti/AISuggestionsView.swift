import SwiftUI
import Combine

struct AISuggestion: Identifiable {
    let id = UUID()
    let title: String
    let reason: String
    let location: String
    let winner: String
    let score: Int
}

@MainActor
final class AISuggestionsViewModel: ObservableObject {
    @Published var prompt: String = "Cena romantica a Milano con atmosfera moderna"
    @Published var suggestions: [AISuggestion] = []
    @Published var isLoading: Bool = false

#if canImport(FoundationModels)
    let modelLabel: String = "Apple Foundation Models (on-device)"
#else
    let modelLabel: String = "Motore locale (fallback compatibile)"
#endif

    func generateSuggestions(from episodes: [Episode]) async {
        let cleanPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanPrompt.isEmpty else {
            suggestions = []
            return
        }

        isLoading = true
        defer { isLoading = false }

        // Local deterministic scoring pipeline: no cloud calls, runs fully on device.
        let tokens = tokenize(cleanPrompt)
        let sorted = episodes
            .map { episode in
                let score = computeScore(for: episode, with: tokens)
                return (episode, score)
            }
            .sorted {
                if $0.1 == $1.1 {
                    return ($0.0.airDate ?? .distantPast) > ($1.0.airDate ?? .distantPast)
                }
                return $0.1 > $1.1
            }
            .prefix(5)

        suggestions = sorted.map { episode, score in
            AISuggestion(
                title: "\(episode.Location) - \(episode.Tema)",
                reason: buildReason(for: episode, with: tokens, score: score),
                location: episode.Location,
                winner: episode.Vincitore,
                score: score
            )
        }
    }

    private func tokenize(_ text: String) -> [String] {
        text
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 }
    }

    private func computeScore(for episode: Episode, with tokens: [String]) -> Int {
        let haystack = [
            episode.Location,
            episode.Tema,
            episode.Concorrenti,
            episode.Vincitore,
            episode.Titolare,
            episode.Categoria_speciale ?? ""
        ]
            .joined(separator: " ")
            .lowercased()

        var score = 0
        for token in tokens {
            if haystack.contains(token) {
                score += 14
            }
        }

        if tokens.contains(where: { ["romantica", "romantico", "date"].contains($0) }) &&
            episode.Tema.lowercased().contains("ristorante") {
            score += 10
        }

        if tokens.contains(where: { ["moderna", "moderno", "fusion", "etnico"].contains($0) }) &&
            episode.Tema.lowercased().contains("etnico") {
            score += 8
        }

        if tokens.contains(where: { ["milano", "roma", "napoli", "torino"].contains($0) }) &&
            tokens.contains(episode.Location.lowercased()) {
            score += 25
        }

        return score
    }

    private func buildReason(for episode: Episode, with tokens: [String], score: Int) -> String {
        var factors: [String] = []

        if tokens.contains(episode.Location.lowercased()) {
            factors.append("match sulla citta")
        }

        if tokens.contains(where: { episode.Tema.lowercased().contains($0) }) {
            factors.append("tema in linea")
        }

        if factors.isEmpty {
            factors.append("coerenza generale con la tua richiesta")
        }

        return "\(factors.joined(separator: ", ")). Punteggio locale: \(score)."
    }
}

struct AISuggestionsView: View {
    @ObservedObject var dataService: DataService
    @StateObject private var viewModel = AISuggestionsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Suggerimenti AI")
                            .font(.title.bold())
                        Label(viewModel.modelLabel, systemImage: "cpu")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text("Elaborazione in locale sul dispositivo. Nessun invio a servizi cloud.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descrivi cosa cerchi")
                            .font(.headline)

                        TextField("Es. cena romantica, cucina contemporanea, zona Navigli", text: $viewModel.prompt, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...5)
                    }

                    Button {
                        Task {
                            await viewModel.generateSuggestions(from: dataService.episodes)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text(viewModel.isLoading ? "Analisi in corso..." : "Genera suggerimenti")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading)

                    if viewModel.suggestions.isEmpty, !viewModel.isLoading {
                        ContentUnavailableView(
                            "Nessun suggerimento",
                            systemImage: "lightbulb",
                            description: Text("Inserisci una richiesta e premi Genera suggerimenti.")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                    }

                    ForEach(viewModel.suggestions) { suggestion in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(suggestion.title)
                                    .font(.headline)
                                    .lineLimit(2)
                                Spacer()
                                Text("\(suggestion.score)")
                                    .font(.caption.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.blue.opacity(0.15), in: Capsule())
                            }

                            Text(suggestion.reason)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 12) {
                                Label(suggestion.location, systemImage: "mappin.and.ellipse")
                                Label(suggestion.winner, systemImage: "trophy")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .padding()
            }
            .navigationTitle("AI Locale")
        }
    }
}

#Preview {
    AISuggestionsView(dataService: DataService())
}
