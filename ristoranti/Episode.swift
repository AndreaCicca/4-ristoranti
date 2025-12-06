import Foundation
import CoreLocation

struct Episode: Codable, Identifiable {
    var id: String {
        return "\(Anno)-\(Stagione)-\(Puntata)"
    }
    
    let Anno: String
    let Stagione: String
    let Puntata: String
    let Location: String
    let Tema: String
    let Prima_visione: String
    let Categoria_speciale: String?
    let Concorrenti: String
    let Vincitore: String
    let Titolare: String
    let Latitude: Double?
    let Longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case Anno
        case Stagione
        case Puntata
        case Location
        case Tema
        case Prima_visione
        case Categoria_speciale = "Categoria speciale"
        case Concorrenti
        case Vincitore
        case Titolare
        case Latitude
        case Longitude
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = Latitude, let lon = Longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
