import Foundation
import Combine

class DataService: ObservableObject {
    @Published var episodes: [Episode] = []
    
    init() {
        loadEpisodes()
    }
    
    func loadEpisodes() {
        guard let url = Bundle.main.url(forResource: "4ristoranti", withExtension: "json") else {
            // Fallback for preview or if file is just in the project dir but not bundle (Simulator hack)
            // But usually we expect it in Bundle. For now we will print error.
            // Check if we can load from local file system if bundle fails (useful for swiftui previews sometimes if not configured right)
            print("JSON file not found in bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            self.episodes = try decoder.decode([Episode].self, from: data)
            print("Loaded \(self.episodes.count) episodes.")
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
}
