import SwiftUI
#if os(macOS)
import AppKit
#endif

struct EpisodeDetailView: View {
    let episode: Episode
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.08), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(episode.Location)
                            .font(.largeTitle.weight(.heavy))
                        Text("Stagione \(episode.Stagione) • Puntata \(episode.Puntata)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                    VStack(alignment: .leading, spacing: 10) {
                        DetailRow(icon: "tv", title: "Puntata", value: "Stagione \(episode.Stagione), Ep. \(episode.Puntata)")
                        DetailRow(icon: "calendar", title: "Anno", value: episode.Anno)
                        DetailRow(icon: "info.circle", title: "Tema", value: episode.Tema)
                        DetailRow(icon: "play.circle", title: "Prima Visione", value: episode.formattedDate)

                        if let categoria = episode.Categoria_speciale, !categoria.isEmpty {
                            DetailRow(icon: "star", title: "Categoria Speciale", value: categoria)
                        }
                    }
                    .padding()
#if os(iOS) || targetEnvironment(macCatalyst)
                    .background(Color(.secondarySystemBackground))
#else
                    .background(Color(NSColor.windowBackgroundColor))
#endif
                    .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Vincitore")
                            .font(.headline)

                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(.yellow)
                                .font(.title)

                            VStack(alignment: .leading) {
                                Text(episode.Vincitore)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("Titolare: \(episode.Titolare)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow, lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Apri in mappe")
                            .font(.headline)

                        HStack(spacing: 10) {
                            Button {
                                openURL(appleMapsURL())
                            } label: {
                                Label("Apple Maps", systemImage: "map")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)

                            Button {
                                openURL(googleMapsURL())
                            } label: {
                                Label("Google Maps", systemImage: "globe")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Concorrenti")
                            .font(.headline)

                        let concorrenti = episode.Concorrenti.components(separatedBy: ",")
                        ForEach(concorrenti, id: \.self) { concorrente in
                            Link(destination: searchURL(for: concorrente)) {
                                HStack {
                                    Text(concorrente.trimmingCharacters(in: .whitespaces))
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(.blue)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
#if os(iOS) || targetEnvironment(macCatalyst)
                                .background(Color(.secondarySystemBackground))
#else
                                .background(Color(NSColor.windowBackgroundColor))
#endif
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(episode.Location)
    #if os(iOS) || targetEnvironment(macCatalyst)
        .navigationBarTitleDisplayMode(.inline)
    #endif
    }
    
    func searchURL(for query: String) -> URL {
        let cleanedQuery = "\(query) \(episode.Location)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.google.com/search?q=\(cleanedQuery)")!
    }

    func appleMapsURL() -> URL {
        let queryText = "\(episode.Vincitore) \(episode.Location)"
        let query = queryText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "http://maps.apple.com/?q=\(query)")!
    }

    func googleMapsURL() -> URL {
        let queryText = "\(episode.Vincitore) \(episode.Location)"
        let query = queryText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.google.com/maps/search/?api=1&query=\(query)")!
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.secondary)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }
}

#Preview {
    EpisodeDetailView(episode: Episode(
        Anno: "2015",
        Stagione: "1",
        Puntata: "1",
        Location: "Milano",
        Tema: "Miglior ristorante post-etnico",
        Prima_visione: "04-mar-15",
        Categoria_speciale: "Prezzo",
        Concorrenti: "Bomaki, la Gnoccheria, Smøøshi, The Boidem",
        Vincitore: "Smøøshi",
        Titolare: "Luca",
        Latitude: 45.4641943,
        Longitude: 9.1896346
    ))
}
