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
        Map(position: $position, selection: $selectedGroup) {
            ForEach(groupedEpisodes) { group in
                Marker(group.title, coordinate: group.coordinate)
                    .tag(group)
            }
        }
        .sheet(item: $selectedGroup) { group in
            GroupDetailSheet(group: group)
                .presentationDetents([.medium, .large])
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
                        VStack(alignment: .leading) {
                            Text(episode.Tema)
                                .font(.headline)
                            Text("Stagione \(episode.Stagione) - Puntata \(episode.Puntata)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .navigationTitle(group.episodes.first?.Location ?? "Episodi")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    RestaurantMapView(dataService: DataService())
}
