import SwiftUI
import MapKit
import CoreLocation

struct RankedNearestEpisode: Identifiable {
    let id: String
    let rank: Int
    let episode: Episode
    let distance: Double
}

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

    var rankedNearestEpisodes: [RankedNearestEpisode] {
        nearestEpisodes.enumerated().map { index, item in
            RankedNearestEpisode(
                id: item.episode.id,
                rank: index + 1,
                episode: item.episode,
                distance: item.distance
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.08), Color.cyan.opacity(0.08), Color.clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 14) {
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
                        .frame(height: 230)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                        )
                        .padding(.horizontal)

                        List {
                            Section {
                                ForEach(rankedNearestEpisodes) { item in
                                    NavigationLink(destination: EpisodeDetailView(episode: item.episode)) {
                                        NearestEpisodeRow(item: item)
                                    }
                                }
                            } header: {
                                Text("Più vicini a te")
                                    .textCase(nil)
                                    .font(.headline)
                            }
                        }
                        .scrollContentBackground(.hidden)
#if os(macOS)
                        .listStyle(.automatic)
#else
                        .listStyle(.insetGrouped)
#endif
                    }
                }
            }
            .navigationTitle("Vicino a me")
            .onAppear {
                locationManager.requestPermission()
            }
        }
    }
}

private struct NearestEpisodeRow: View {
    let item: RankedNearestEpisode

    var body: some View {
        HStack(spacing: 12) {
            Text("#\(item.rank)")
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(.blue.opacity(0.12), in: Capsule())

            VStack(alignment: .leading, spacing: 4) {
                Text(item.episode.Location)
                    .font(.headline)
                Text(item.episode.Tema)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Text(String(format: "%.1f km", item.distance / 1000))
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
        }
    }
}

#Preview {
    NearestLocationsView(dataService: DataService())
}
