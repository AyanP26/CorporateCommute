import Foundation
import MapKit
import Combine

struct LocationSearchResult: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var title: String
    var subtitle: String
}

final class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchQuery: String = ""
    @Published var searchResults: [LocationSearchResult] = []
    @Published var isSearching: Bool = false
    @Published var errorMessage: String? = nil

    private let completer = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]

        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                let trimmed = query.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty {
                    self.searchResults = []
                    self.isSearching = false
                    self.completer.queryFragment = ""
                } else {
                    self.isSearching = true
                    self.completer.queryFragment = trimmed
                }
            }
            .store(in: &cancellables)
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results.map {
                LocationSearchResult(title: $0.title, subtitle: $0.subtitle)
            }
            self.isSearching = false
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isSearching = false
            self.errorMessage = error.localizedDescription
        }
    }

    /// Resolves an autocompleted result into high-precision Apple Maps coordinates and formatted address
    func resolveLocation(for result: LocationSearchResult) async throws -> CommuteLocation {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = result.subtitle.isEmpty ? result.title : "\(result.title), \(result.subtitle)"
        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        guard let mapItem = response.mapItems.first else {
            throw NSError(
                domain: "LocationSearch",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Could not find coordinates for \(result.title)"]
            )
        }

        let coord = mapItem.placemark.coordinate
        let formattedAddress = [
            mapItem.placemark.subThoroughfare,
            mapItem.placemark.thoroughfare,
            mapItem.placemark.locality,
            mapItem.placemark.administrativeArea
        ].compactMap { $0 }.joined(separator: " ")

        return CommuteLocation(
            name: mapItem.name ?? result.title,
            address: formattedAddress.isEmpty ? (result.subtitle.isEmpty ? result.title : result.subtitle) : formattedAddress,
            latitude: coord.latitude,
            longitude: coord.longitude
        )
    }

    /// Geocodes a coordinate back into a readable street address using Apple Maps reverse geocoding
    func reverseGeocode(coordinate: CLLocationCoordinate2D) async -> CommuteLocation {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(clLocation)
            if let place = placemarks.first {
                let name = place.name ?? place.thoroughfare ?? "Selected Map Location"
                let address = [place.subThoroughfare, place.thoroughfare, place.locality, place.administrativeArea]
                    .compactMap { $0 }
                    .joined(separator: " ")
                return CommuteLocation(
                    name: name,
                    address: address.isEmpty ? "\(String(format: "%.4f", coordinate.latitude)), \(String(format: "%.4f", coordinate.longitude))" : address,
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
            }
        } catch {}

        return CommuteLocation(
            name: "Selected Location",
            address: "\(String(format: "%.4f", coordinate.latitude)), \(String(format: "%.4f", coordinate.longitude))",
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }
}
