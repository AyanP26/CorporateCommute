import Foundation
import CoreLocation

struct CommuteLocation: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double

    init(
        id: String = UUID().uuidString,
        name: String,
        address: String,
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var dictionaryRepresentation: [String: Any] {
        return [
            "id": id,
            "name": name,
            "address": address,
            "latitude": latitude,
            "longitude": longitude
        ]
    }

    init?(dictionary: [String: Any]) {
        guard let name = dictionary["name"] as? String,
              let address = dictionary["address"] as? String,
              let latitude = dictionary["latitude"] as? Double,
              let longitude = dictionary["longitude"] as? Double else {
            return nil
        }
        self.id = dictionary["id"] as? String ?? UUID().uuidString
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }

    // Default presets for quick-pick
    static let corporateHQ = CommuteLocation(
        name: "Corporate HQ - Innovation Campus",
        address: "1 Infinite Loop, Cupertino, CA",
        latitude: 37.33182,
        longitude: -122.03118
    )

    static let techPark = CommuteLocation(
        name: "Silicon Tech Park - Building B",
        address: "100 Innovation Way, San Jose, CA",
        latitude: 37.33820,
        longitude: -121.88633
    )

    static let downtownHub = CommuteLocation(
        name: "Downtown Corporate Center",
        address: "500 Market St, San Francisco, CA",
        latitude: 37.79004,
        longitude: -122.40079
    )

    static let transitStation = CommuteLocation(
        name: "Regional Commuter Rail Station",
        address: "Transit Center Plaza, Palo Alto, CA",
        latitude: 37.44300,
        longitude: -122.16490
    )

    static let samplePresets: [CommuteLocation] = [
        corporateHQ,
        techPark,
        downtownHub,
        transitStation
    ]
}
