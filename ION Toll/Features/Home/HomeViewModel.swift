import Foundation
import Observation
import CoreLocation

@Observable
@MainActor
final class HomeViewModel: NSObject, CLLocationManagerDelegate {
    var isLoading = false
    var balance: Double = 0
    var showCompleteProfilePrompt = false
    var locationString = "Mendapatkan lokasi..."

    let sessionManager: SessionManager
    private let locationManager = CLLocationManager()

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        super.init()
        locationManager.delegate = self
        checkProfileCompletion()
        requestLocation()
    }

    var currentUser: User? {
        sessionManager.currentUser
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Selamat Pagi"
        case 12..<15: return "Selamat Siang"
        case 15..<18: return "Selamat Sore"
        default: return "Selamat Malam"
        }
    }

    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        let formatted = formatter.string(from: NSNumber(value: balance)) ?? "0"
        return "Rp\(formatted)"
    }

    var isGuest: Bool {
        sessionManager.isGuest
    }

    func checkProfileCompletion() {
        if let user = sessionManager.currentUser, user.needsProfileCompletion {
            showCompleteProfilePrompt = true
        }
    }

    func loadHomeData() async {
        // Future: fetch wallet balance, services, etc.
    }

    // MARK: - Location

    private func requestLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            if let location = locationManager.location {
                reverseGeocode(location)
            } else {
                locationManager.requestLocation()
            }
        default:
            locationString = "Indonesia"
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                if let location = manager.location {
                    reverseGeocode(location)
                } else {
                    manager.requestLocation()
                }
            case .denied, .restricted:
                locationString = "Indonesia"
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            reverseGeocode(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationString = "Indonesia"
        }
    }

    private func reverseGeocode(_ location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            Task { @MainActor in
                if let placemark = placemarks?.first {
                    let parts = [placemark.thoroughfare, placemark.subLocality, placemark.locality].compactMap { $0 }
                    self.locationString = parts.isEmpty ? "Indonesia" : parts.joined(separator: ", ")
                } else {
                    self.locationString = "Indonesia"
                }
            }
        }
    }
}
