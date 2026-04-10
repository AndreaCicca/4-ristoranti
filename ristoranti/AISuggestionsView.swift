import SwiftUI
import Combine
#if canImport(FoundationModels)
import FoundationModels
#endif

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
    @Published var engineStatus: String = ""

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

#if canImport(FoundationModels)
        if #available(macOS 26.0, iOS 26.0, visionOS 26.0, *) {
            if let aiSuggestions = try? await generateWithFoundationModel(prompt: cleanPrompt, episodes: episodes), !aiSuggestions.isEmpty {
                suggestions = aiSuggestions
                return
            }
        }
#endif

        // Local deterministic scoring pipeline: no cloud calls, runs fully on device.
        engineStatus = "Fallback locale attivo"
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

#if canImport(FoundationModels)
    @available(macOS 26.0, iOS 26.0, visionOS 26.0, *)
    private func generateWithFoundationModel(prompt: String, episodes: [Episode]) async throws -> [AISuggestion] {
        let model = SystemLanguageModel.default
        guard case .available = model.availability else {
            engineStatus = "Modello Apple non disponibile su questo dispositivo"
            return []
        }

        if !model.supportsLocale(Locale(identifier: "it_IT")) {
            engineStatus = "Locale non supportata dal modello, uso fallback"
            return []
        }

        let compactEpisodes = episodes.prefix(80).map { episode in
            "- \(episode.Location) | \(episode.Tema) | vincitore: \(episode.Vincitore)"
        }.joined(separator: "\n")

        let instructions = """
        Sei un assistente che suggerisce episodi del dataset di 4 Ristoranti.
        Devi proporre massimo 5 suggerimenti coerenti con la richiesta.
        Rispondi solo con righe in questo formato, senza testo aggiuntivo:
        location|winner|reason|score
        score deve essere un intero tra 0 e 100.
        reason deve essere breve e in italiano.
        """

        let session = LanguageModelSession(instructions: instructions)
        let fullPrompt = """
        Richiesta utente: \(prompt)

        Episodi disponibili:
        \(compactEpisodes)
        """

        let options = GenerationOptions(temperature: 0.4)
        let response = try await session.respond(to: fullPrompt, options: options)
        let rawOutput = String(describing: response)

        let parsed = parseModelOutput(rawOutput, episodes: episodes)
        if parsed.isEmpty {
            engineStatus = "Output AI non strutturato, uso fallback"
        } else {
            engineStatus = "Suggerimenti generati da Apple Foundation Models"
        }
        return parsed
    }

    private func parseModelOutput(_ text: String, episodes: [Episode]) -> [AISuggestion] {
        var items: [AISuggestion] = []

        let lines = text
            .split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.contains("|") }

        for line in lines.prefix(5) {
            let parts = line.split(separator: "|", omittingEmptySubsequences: false).map {
                String($0).trimmingCharacters(in: .whitespacesAndNewlines)
            }

            guard parts.count >= 4 else { continue }

            let location = parts[0]
            let winner = parts[1]
            let reason = parts[2]
            let score = max(0, min(100, Int(parts[3]) ?? 60))

            let matchedEpisode = episodes.first {
                $0.Location.localizedCaseInsensitiveContains(location) ||
                location.localizedCaseInsensitiveContains($0.Location)
            }

            let title: String
            if let matchedEpisode {
                title = "\(matchedEpisode.Location) - \(matchedEpisode.Tema)"
            } else {
                title = "\(location) - Suggerimento AI"
            }

            items.append(
                AISuggestion(
                    title: title,
                    reason: reason,
                    location: location,
                    winner: winner,
                    score: score
                )
            )
        }

        return items
    }
#endif

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
                        if !viewModel.engineStatus.isEmpty {
                            Text(viewModel.engineStatus)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
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
