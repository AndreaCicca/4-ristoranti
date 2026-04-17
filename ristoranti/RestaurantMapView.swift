import SwiftUI
import MapKit

struct RestaurantMapView: View {
    @ObservedObject var dataService: DataService
    @StateObject private var locationManager = LocationManager()
    
    // Center on Italy
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 41.8719, longitude: 12.5674),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )
    
    @State private var selectedGroup: LocationGroup?
    @State private var isWaitingForLocation = false
    
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
                    UserAnnotation()
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
                        centerOnUserLocation()
                    } label: {
                        Image(systemName: locationManager.userLocation == nil ? "location" : "location.fill")
                            .font(.headline)
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .navigationTitle("Mappa")
            .onChange(of: locationManager.userLocation) { _, newLocation in
                if isWaitingForLocation, let location = newLocation {
                    isWaitingForLocation = false
                    position = .region(
                        MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45)
                        )
                    )
                }
            }
            .navigationDestination(item: $selectedGroup) { group in
                GroupDetailSheet(group: group)
            }
        }
    }

    private func centerOnUserLocation() {
        guard let userLocation = locationManager.userLocation else {
            isWaitingForLocation = true
            locationManager.requestPermission()
            return
        }

        position = .region(
            MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45)
            )
        )
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
        Group {
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
                                    .background(.cyan.opacity(0.15), in: Capsule())
                                    .foregroundStyle(.cyan)
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
