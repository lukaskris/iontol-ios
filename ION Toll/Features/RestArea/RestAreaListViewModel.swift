import Foundation
import Observation
import CoreLocation

@Observable
@MainActor
final class RestAreaListViewModel: NSObject, CLLocationManagerDelegate {
    var items: [RestAreaItem] = []
    var isLoading = true
    var errorMessage: String?

    private let locationManager = CLLocationManager()
    private let repository = RestAreaRepository()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        let status = locationManager.authorizationStatus
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            isLoading = false
            errorMessage = "Lokasi tidak aktif. Aktifkan lokasi untuk melihat rest area terdekat."
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            case .denied, .restricted:
                isLoading = false
                errorMessage = "Lokasi tidak aktif. Aktifkan lokasi untuk melihat rest area terdekat."
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            await loadItems(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            isLoading = false
            errorMessage = "Lokasi tidak aktif"
        }
    }

    func retry() {
        isLoading = true
        errorMessage = nil
        requestLocation()
    }

    private func loadItems(latitude: Double, longitude: Double) async {
        isLoading = true
        errorMessage = nil
        do {
            items = try await repository.getList(latitude: latitude, longitude: longitude)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
