//
//  WeatherService.swift
//  LocalWeather
//

import Foundation
import CoreLocation
import Combine

class WeatherService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentWeather: WeatherData?
    @Published var isLoading = true
    
    override init() {
        super.init()
        // Show weather after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.provideDefaultWeather()
        }
    }
    
    func requestLocation() {
        isLoading = true
        provideDefaultWeather()
    }
    
    func searchCity(_ city: String) {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.provideDefaultWeather()
        }
    }
    
    func provideDefaultWeather() {
        let weather = WeatherData(
            temperature: 24,
            high: 28,
            low: 19,
            condition: .sunny,
            humidity: 65,
            windSpeed: 12,
            feelsLike: 26,
            locationName: "San Francisco",
            sunrise: "6:42 AM",
            sunset: "7:38 PM"
        )
        
        DispatchQueue.main.async {
            self.currentWeather = weather
            self.isLoading = false
        }
    }
    
    // MARK: - Location Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
