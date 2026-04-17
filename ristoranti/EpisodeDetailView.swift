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
                colors: [Color.cyan.opacity(0.12), Color.blue.opacity(0.04), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                #if os(macOS) || targetEnvironment(macCatalyst)
                VStack(spacing: 20) {
                    // Top Row
                    HStack(spacing: 20) {
                        heroBox
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)
                        infoBox
                            .frame(width: 320)
                            .frame(maxHeight: .infinity)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    
                    // Bottom Row
                    HStack(alignment: .top, spacing: 20) {
                        vincitoreBox
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)
                        concorrentiBox
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)
                        mappeBox
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(32)
                .frame(maxWidth: 1400)
                #else
                VStack(spacing: 20) {
                    heroBox
                    infoBox
                    vincitoreBox
                    concorrentiBox
                    mappeBox
                }
                .padding(20)
                #endif
            }
        }
        .navigationTitle(episode.Location)
    #if os(iOS) || targetEnvironment(macCatalyst)
        .navigationBarTitleDisplayMode(.inline)
    #endif
    }
    
    // MARK: - Bento Boxes
    
    private var heroBox: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(episode.Location)
                .font(.system(size: 42, weight: .heavy, design: .rounded))
            Text("Stagione \(episode.Stagione) • Puntata \(episode.Puntata)")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }
    
    private var infoBox: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.cyan)
                Text("Tema")
                    .font(.headline)
            }
            
            Text(episode.Tema)
                .font(.title3.weight(.medium))
                .lineLimit(4)
                
            Spacer(minLength: 16)
            Divider()
            
            HStack {
                Label("Prima visione", systemImage: "calendar")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(episode.formattedDate)
                    .font(.caption.monospacedDigit())
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.blue.opacity(0.05))
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.blue.opacity(0.15), lineWidth: 1)
        )
    }
    
    private var vincitoreBox: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Vincitore")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "trophy.fill")
                    .font(.title)
                    .foregroundStyle(.yellow)
            }
            
            Spacer(minLength: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(episode.Vincitore)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text("Titolare: \(episode.Titolare)")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: [Color.orange, Color.red.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.orange.opacity(0.3), radius: 12, x: 0, y: 6)
    }
    
    private var concorrentiBox: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Concorrenti")
                .font(.headline)
                
            let concorrenti = episode.Concorrenti.components(separatedBy: ",")
            VStack(spacing: 8) {
                ForEach(concorrenti, id: \.self) { concorrente in
                    Link(destination: searchURL(for: concorrente)) {
                        HStack {
                            Text(concorrente.trimmingCharacters(in: .whitespaces))
                                .font(.callout)
                            Spacer()
                            Image(systemName: "magnifyingglass.circle.fill")
                                .foregroundStyle(.purple)
                                .font(.title3)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.purple.opacity(0.03))
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.purple.opacity(0.15), lineWidth: 1)
        )
    }
    
    private var mappeBox: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Naviga")
                .font(.headline)
            
            Spacer(minLength: 16)
            
            VStack(spacing: 12) {
                Button {
                    openURL(appleMapsURL())
                } label: {
                    Label("Apri in Apple Maps", systemImage: "map.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .controlSize(.large)
                
                Button {
                    openURL(googleMapsURL())
                } label: {
                    Label("Apri in Google Maps", systemImage: "globe")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.cyan.opacity(0.05))
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.cyan.opacity(0.2), lineWidth: 1)
        )
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
