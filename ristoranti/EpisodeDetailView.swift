import SwiftUI

struct EpisodeDetailView: View {
    let episode: Episode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(episode.Location)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 10) {
                    DetailRow(icon: "tv", title: "Puntata", value: "Stagione \(episode.Stagione), Ep. \(episode.Puntata)")
                    DetailRow(icon: "calendar", title: "Anno", value: episode.Anno)
                    DetailRow(icon: "info.circle", title: "Tema", value: episode.Tema)
                    DetailRow(icon: "play.circle", title: "Prima Visione", value: episode.Prima_visione)
                    
                    if let categoria = episode.Categoria_speciale, !categoria.isEmpty {
                        DetailRow(icon: "star", title: "Categoria Speciale", value: categoria)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
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
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(episode.Location)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func searchURL(for query: String) -> URL {
        let cleanedQuery = "\(query) \(episode.Location)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.google.com/search?q=\(cleanedQuery)")!
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
