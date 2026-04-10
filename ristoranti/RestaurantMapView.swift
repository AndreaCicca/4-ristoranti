import SwiftUI
import MapKit

struct RestaurantMapView: View {
    @ObservedObject var dataService: DataService
    
    // Center on Italy
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.8719, longitude: 12.5674),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )
    
    @State private var selectedGroup: LocationGroup?
    
    var groupedEpisodes: [LocationGroup] {
        let grouped = Dictionary(grouping: dataService.episodes.filter { $0.Location != "Italia" }) { episode -> String in
            guard let lat = episode.Latitude, let lon = episode.Longitude else { return "unknown" }
            return String(format: "%.6f,%.6f", lat, lon)
        }
        
        return grouped.compactMap { (_, episodes) -> LocationGroup? in
            guard let first = episodes.first, let coordinate = first.coordinate else { return nil }
            return LocationGroup(id: first.id, coordinate: coordinate, episodes: episodes)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Map(position: $position, selection: $selectedGroup) {
                    ForEach(groupedEpisodes) { group in
                        Marker(group.title, coordinate: group.coordinate)
                            .tag(group)
                    }
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mappa Ristoranti")
                            .font(.headline.weight(.bold))
                        Text("\(groupedEpisodes.count) location")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        position = .region(
                            MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: 41.8719, longitude: 12.5674),
                                span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
                            )
                        )
                    } label: {
                        Image(systemName: "scope")
                            .font(.headline)
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .navigationTitle("Mappa")
        }
        .sheet(item: $selectedGroup) { group in
#if os(iOS) || targetEnvironment(macCatalyst)
            // Prefer a large detent when the group has multiple episodes
            if group.episodes.count > 1 {
                GroupDetailSheet(group: group)
                    .presentationDetents([.large])
            } else {
                GroupDetailSheet(group: group)
                    .presentationDetents([.medium, .large])
            }
#else
            // On macOS present a larger sheet window when multiple episodes exist
            GroupDetailSheet(group: group)
                .frame(minWidth: 500, minHeight: group.episodes.count > 1 ? 600 : 400)
#endif
        }
    }
}

struct LocationGroup: Identifiable, Hashable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let episodes: [Episode]
    
    var title: String {
        episodes.count > 1 ? "\(episodes.first?.Location ?? "") (\(episodes.count))" : (episodes.first?.Location ?? "")
    }
    
    static func == (lhs: LocationGroup, rhs: LocationGroup) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct GroupDetailSheet: View {
    let group: LocationGroup
    
    var body: some View {
        NavigationStack {
            if group.episodes.count == 1, let episode = group.episodes.first {
                EpisodeDetailView(episode: episode)
            } else {
                List(group.episodes) { episode in
                    NavigationLink(destination: EpisodeDetailView(episode: episode)) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(episode.Tema)
                                .font(.headline.weight(.semibold))
                            HStack {
                                Text("Stagione \(episode.Stagione) - Puntata \(episode.Puntata)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(episode.Vincitore)
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.blue.opacity(0.12), in: Capsule())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .navigationTitle(group.episodes.first?.Location ?? "Episodi")
#if os(iOS) || targetEnvironment(macCatalyst)
                .navigationBarTitleDisplayMode(.inline)
#endif
            }
        }
    }
}

#Preview {
    RestaurantMapView(dataService: DataService())
}
