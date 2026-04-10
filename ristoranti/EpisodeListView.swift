import SwiftUI

struct EpisodeListView: View {
    @ObservedObject var dataService: DataService
    @State private var searchText = ""
    
    var filteredEpisodes: [Episode] {
        if searchText.isEmpty {
            return dataService.episodes
        } else {
            return dataService.episodes.filter { episode in
                episode.Location.localizedCaseInsensitiveContains(searchText) ||
                episode.Vincitore.localizedCaseInsensitiveContains(searchText) ||
                episode.Concorrenti.localizedCaseInsensitiveContains(searchText) ||
                episode.Tema.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var episodesBySeason: [String: [Episode]] {
        Dictionary(grouping: filteredEpisodes, by: { $0.Stagione })
    }
    
    var sortedSeasons: [String] {
        episodesBySeason.keys.sorted {
            (Int($0) ?? 0) > (Int($1) ?? 0) // Sort recent seasons first
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedSeasons, id: \.self) { season in
                    Section {
                        ForEach(episodesBySeason[season]!) { episode in
                            NavigationLink(destination: EpisodeDetailView(episode: episode)) {
                                HStack(alignment: .top, spacing: 14) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(episode.Location)
                                            .font(.title3.weight(.bold))
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)

                                        Text(episode.Tema)
                                            .font(.footnote.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }

                                    Spacer(minLength: 12)

                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Stagione \(season)")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(.secondary)
                                            .textCase(.uppercase)

                                        Text(episode.Vincitore)
                                            .font(.headline.weight(.semibold))
                                            .multilineTextAlignment(.trailing)
                                            .lineLimit(2)

                                        Text("Ep. \(episode.Puntata)")
                                            .font(.caption2.monospacedDigit())
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.primary.opacity(0.05))
                                    .padding(.vertical, 4)
                            )
                        }
                    } header: {
                        Text("Stagione \(season)")
                            .font(.headline.weight(.heavy))
                            .foregroundStyle(.primary)
                            .textCase(nil)
                    }
                }
            }
#if os(macOS)
            .listStyle(.automatic)
#else
            .listStyle(.insetGrouped)
#endif
            .navigationTitle("Episodi")
            .searchable(text: $searchText, prompt: "Cerca location, vincitore...")
            .overlay {
                if filteredEpisodes.isEmpty {
                    ContentUnavailableView.search
                }
            }
        }
    }
}

#Preview {
    EpisodeListView(dataService: DataService())
}
