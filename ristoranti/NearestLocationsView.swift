import SwiftUI
import MapKit
import CoreLocation

struct NearestLocationsView: View {
    @ObservedObject var dataService: DataService
    @StateObject private var locationManager = LocationManager()
    
    var nearestEpisodes: [(episode: Episode, distance: Double)] {
        guard let userLoc = locationManager.userLocation else { return [] }
        
        let sorted = dataService.episodes.compactMap { episode -> (Episode, Double)? in
            guard episode.Location != "Italia" else { return nil }
            guard let lat = episode.Latitude, let lon = episode.Longitude else { return nil }
            let episodeLoc = CLLocation(latitude: lat, longitude: lon)
            let distance = userLoc.distance(from: episodeLoc)
            return (episode, distance)
        }.sorted { $0.1 < $1.1 }
        
        return Array(sorted.prefix(5))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if locationManager.authorizationStatus == .denied {
                    ContentUnavailableView("Permesso Negato", systemImage: "location.slash", description: Text("Abilita la posizione nelle impostazioni per vedere i ristoranti vicini."))
                } else if locationManager.userLocation == nil {
                    ProgressView("Ricerca posizione...")
                } else {
                    // Mini Map
                    Map() {
                        UserAnnotation()
                        ForEach(nearestEpisodes, id: \.episode.id) { item in
                            if let coordinate = item.episode.coordinate {
                                Marker(item.episode.Location, coordinate: coordinate)
                                    .tint(.red)
                            }
                        }
                    }
                    .frame(height: 250)
                    .cornerRadius(12)
                    .padding()
                    
                    // List
                    List {
                        ForEach(nearestEpisodes, id: \.episode.id) { item in
                            NavigationLink(destination: EpisodeDetailView(episode: item.episode)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.episode.Location)
                                            .font(.headline)
                                        Text(item.episode.Tema)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text(String(format: "%.1f km", item.distance / 1000))
                                            .font(.headline)
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Vicino a me")
            .onAppear {
                locationManager.requestPermission()
            }
        }
    }
}

#Preview {
    NearestLocationsView(dataService: DataService())
}
