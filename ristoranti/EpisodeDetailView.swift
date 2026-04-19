import SwiftUI
import MapKit
#if os(macOS)
import AppKit
#endif

struct EpisodeDetailView: View {
    let episode: Episode
    @Environment(\.openURL) private var openURL
    
    @State private var appleMapClicks = 0
    @State private var googleMapClicks = 0
    @State private var animateTrophy = 0
    @State private var winnerMapItem: MKMapItem?
    
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
                Grid(horizontalSpacing: 20, verticalSpacing: 20) {
                    GridRow {
                        heroBox
                            .gridCellColumns(2)
                        infoBox
                            .gridCellColumns(1)
                    }
                    
                    GridRow {
                        vincitoreBox
                        concorrentiBox
                        mappeBox
                    }
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
        .task {
            let query = "\(episode.Vincitore) \(episode.Location)"
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            if let coord = episode.coordinate {
                request.region = MKCoordinateRegion(center: coord, latitudinalMeters: 30000, longitudinalMeters: 30000)
            }
            
            do {
                let search = MKLocalSearch(request: request)
                let response = try await search.start()
                if let item = response.mapItems.first {
                    await MainActor.run {
                        withAnimation {
                            self.winnerMapItem = item
                        }
                    }
                }
            } catch {
                print("MapKit error: \(error)")
            }
        }
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
        .bentoHover(glowColor: .primary.opacity(0.2))
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
        .bentoHover(glowColor: .blue)
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
                    .symbolEffect(.bounce, value: animateTrophy)
                    .onTapGesture {
                        animateTrophy += 1
                    }
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
            
            if let mapItem = winnerMapItem {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(.white.opacity(0.3))
                        .padding(.vertical, 8)
                    
                    if let address = mapItem.placemark.title {
                        HStack(alignment: .top) {
                            Image(systemName: "mappin.and.ellipse")
                            Text(address)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    }
                    
                    HStack(spacing: 16) {
                        if let phone = mapItem.phoneNumber, let phoneURL = URL(string: "tel://\(phone.filter { !$0.isWhitespace })") {
                            Button {
                                openURL(phoneURL)
                            } label: {
                                Image(systemName: "phone.fill")
                                    .padding(10)
                                    .background(.white.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.white)
                        }
                        
                        if let url = mapItem.url {
                            Button {
                                openURL(url)
                            } label: {
                                Image(systemName: "globe")
                                    .padding(10)
                                    .background(.white.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.white)
                        }
                    }
                }
                .transition(.opacity)
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
        .bentoHover(glowColor: .orange)
    }
    
    private var concorrentiBox: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Concorrenti")
                .font(.headline)
                
            let concorrenti = episode.Concorrenti.components(separatedBy: ",")
            VStack(spacing: 8) {
                ForEach(concorrenti, id: \.self) { concorrente in
                    CompetitorRow(name: concorrente, searchURL: searchURL(for: concorrente))
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
        .bentoHover(glowColor: .purple)
    }
    
    private var mappeBox: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Naviga")
                .font(.headline)
            
            Spacer(minLength: 8)
            
            VStack(spacing: 16) {
                Button {
                    appleMapClicks += 1
                    openURL(appleMapsURL())
                } label: {
                    HStack {
                        Image(systemName: "map.fill")
                            .font(.title2)
                            .symbolEffect(.bounce, value: appleMapClicks)
                        
                        Text("Apple Maps")
                            .font(.title3.weight(.bold))
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(colors: [Color.cyan, Color.blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.cyan.opacity(0.4), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                
                Button {
                    googleMapClicks += 1
                    openURL(googleMapsURL())
                } label: {
                    HStack {
                        Image(systemName: "globe")
                            .font(.title2)
                            .symbolEffect(.bounce, value: googleMapClicks)
                        
                        Text("Google Maps")
                            .font(.title3.weight(.bold))
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right.circle")
                            .font(.title2)
                            .foregroundStyle(.cyan)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.6))
                    .foregroundStyle(.cyan.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.cyan.opacity(0.3), lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
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
        .bentoHover(glowColor: .cyan)
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

// MARK: - View Modifiers & Helpers

struct BentoHoverModifier: ViewModifier {
    let glowColor: Color
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(color: isHovered ? glowColor.opacity(0.4) : .clear, radius: isHovered ? 24 : 0, x: 0, y: isHovered ? 8 : 0)
            .animation(.interpolatingSpring(stiffness: 250, damping: 20), value: isHovered)
            .onHover { hovering in
                self.isHovered = hovering
            }
    }
}

extension View {
    func bentoHover(glowColor: Color = .cyan) -> some View {
        self.modifier(BentoHoverModifier(glowColor: glowColor))
    }
}

struct CompetitorRow: View {
    let name: String
    let searchURL: URL
    @State private var isHovered = false
    @State private var clickCount = 0
    
    var body: some View {
        Link(destination: searchURL) {
            HStack {
                Text(name.trimmingCharacters(in: .whitespaces))
                    .font(.callout)
                Spacer()
                Image(systemName: "magnifyingglass.circle.fill")
                    .foregroundStyle(.purple)
                    .font(.title3)
                    .symbolEffect(.bounce, value: clickCount)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Color.primary.opacity(isHovered ? 0.08 : 0.04), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hover in
            isHovered = hover
        }
        .simultaneousGesture(TapGesture().onEnded {
            clickCount += 1
        })
    }
}
