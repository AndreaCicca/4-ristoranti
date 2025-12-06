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
                    Section(header: Text("Stagione \(season)")) {
                        ForEach(episodesBySeason[season]!) { episode in
                            NavigationLink(destination: EpisodeDetailView(episode: episode)) {
                                VStack(alignment: .leading) {
                                    Text(episode.Location)
                                        .font(.headline)
                                    Text("Vincitore: \(episode.Vincitore)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
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
