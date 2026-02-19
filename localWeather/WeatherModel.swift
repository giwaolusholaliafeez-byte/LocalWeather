//
//  WeatherModel.swift
//  LocalWeather
//

import Foundation
import SwiftUI

// Weather data structure
struct WeatherData {
    let temperature: Int
    let high: Int
    let low: Int
    let condition: WeatherCondition
    let humidity: Int
    let windSpeed: Int
    let feelsLike: Int
    let locationName: String
    let sunrise: String
    let sunset: String
}

// Weather condition enum
enum WeatherCondition: String {
    case sunny = "Sunny"
    case cloudy = "Cloudy"
    case rainy = "Rainy"
    case snowy = "Snowy"
    case partlyCloudy = "Partly Cloudy"
    
    var icon: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "cloud.snow.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .sunny: return .orange
        case .cloudy: return .gray
        case .rainy: return .blue
        case .snowy: return .cyan
        case .partlyCloudy: return .gray
        }
    }
}
