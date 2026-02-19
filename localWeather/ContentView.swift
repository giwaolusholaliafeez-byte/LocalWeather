//
//  ContentView.swift
//  LocalWeather
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var weatherService = WeatherService()
    @State private var selectedTab = 0
    @State private var isRefreshing = false
    @State private var showSearch = false
    
    var body: some View {
        ZStack {
            // Animated background based on weather
            AnimatedBackground(condition: weatherService.currentWeather?.condition ?? .sunny)
                .ignoresSafeArea()
            
            if weatherService.isLoading {
                // Premium loading animation
                PremiumLoadingView()
            } else if let weather = weatherService.currentWeather {
                VStack(spacing: 0) {
                    // Custom Navigation Bar
                    CustomNavBar(
                        location: weather.locationName,
                        onRefresh: refreshWeather,
                        onSearch: { showSearch.toggle() },
                        isRefreshing: $isRefreshing
                    )
                    
                    // Main Content with Tab View
                    TabView(selection: $selectedTab) {
                        TodayView(weather: weather)
                            .tag(0)
                        
                        HourlyView(weather: weather)
                            .tag(1)
                        
                        WeeklyView()
                            .tag(2)
                        
                        DetailsView(weather: weather)
                            .tag(3)
                        
                        MapView(weather: weather)
                            .tag(4)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // Custom Tab Bar
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView { city in
                weatherService.searchCity(city)
                showSearch = false
            }
        }
        .onAppear {
            weatherService.requestLocation()
        }
    }
    
    func refreshWeather() {
        withAnimation {
            isRefreshing = true
            weatherService.requestLocation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isRefreshing = false
            }
        }
    }
}

// MARK: - Animated Background
struct AnimatedBackground: View {
    let condition: WeatherCondition
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: condition.gradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Animated particles
            if condition == .sunny {
                ForEach(0..<15) { i in
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 4, height: 4)
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: animate ? 0 : UIScreen.main.bounds.height
                        )
                        .animation(
                            Animation.linear(duration: Double.random(in: 5...10))
                                .repeatForever(autoreverses: false),
                            value: animate
                        )
                }
            } else if condition == .rainy {
                ForEach(0..<20) { i in
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue.opacity(0.2))
                        .font(.system(size: 8))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: animate ? UIScreen.main.bounds.height : -50
                        )
                        .animation(
                            Animation.linear(duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: false),
                            value: animate
                        )
                }
            }
        }
        .onAppear { animate.toggle() }
    }
}

// MARK: - Premium Loading View
struct PremiumLoadingView: View {
    @State private var rotation = 0.0
    @State private var scale = 0.8
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: rotation))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
                
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                    .animation(.easeInOut(duration: 1).repeatForever(), value: scale)
            }
            
            Text("Getting your weather...")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Text("Preparing your forecast")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .onAppear {
            rotation = 360
            scale = 1.0
        }
    }
}

// MARK: - Custom Navigation Bar
struct CustomNavBar: View {
    let location: String
    let onRefresh: () -> Void
    let onSearch: () -> Void
    @Binding var isRefreshing: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(location)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Today, \(Date().formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: onSearch) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
                
                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                        .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isRefreshing)
                }
                .disabled(isRefreshing)
            }
        }
        .padding(.horizontal)
        .padding(.top, 50)
    }
}

// MARK: - Today View
struct TodayView: View {
    let weather: WeatherData
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 25) {
                // Main Weather Card
                MainWeatherCard(weather: weather)
                
                // Air Quality Card
                AirQualityCard()
                
                // Precipitation Card
                PrecipitationCard()
                
                // UV Index Card
                UVIndexCard()
            }
            .padding(.horizontal)
            .padding(.bottom, 80)
        }
    }
}

// MARK: - Main Weather Card
struct MainWeatherCard: View {
    let weather: WeatherData
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CURRENT WEATHER")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(weather.temperature)°")
                        .font(.system(size: 72, weight: .thin))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: weather.condition.icon)
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .symbolRenderingMode(.multicolor)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            HStack {
                VStack(alignment: .leading) {
                    Text(weather.condition.rawValue)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Feels like \(weather.feelsLike)°")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    Label("H: \(weather.high)°", systemImage: "arrow.up")
                    Label("L: \(weather.low)°", systemImage: "arrow.down")
                }
                .font(.headline)
                .foregroundColor(.white)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
    }
}

// MARK: - Air Quality Card
struct AirQualityCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("AIR QUALITY", systemImage: "leaf")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.7))
            
            HStack {
                Text("23")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.green)
                
                Text("Good")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Air quality meter
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 100, height: 6)
                    
                    Capsule()
                        .fill(Color.green)
                        .frame(width: 25, height: 6)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Precipitation Card
struct PrecipitationCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("PRECIPITATION", systemImage: "drop")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.7))
            
            HStack {
                Text("0%")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Precipitation chart
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(["Now", "1h", "2h", "3h", "4h"], id: \.self) { hour in
                        VStack {
                            Capsule()
                                .fill(Color.blue)
                                .frame(width: 8, height: CGFloat.random(in: 20...60))
                            Text(hour)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - UV Index Card
struct UVIndexCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label("UV INDEX", systemImage: "sun.max")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.7))
            
            HStack {
                Text("4")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.orange)
                
                Text("Moderate")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                // UV meter
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 100, height: 6)
                    
                    Capsule()
                        .fill(Color.orange)
                        .frame(width: 50, height: 6)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Hourly View
struct HourlyView: View {
    let weather: WeatherData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("HOURLY FORECAST")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(0..<24) { hour in
                            HourlyCard(hour: hour, weather: weather)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 80)
        }
    }
}

// MARK: - Hourly Card
struct HourlyCard: View {
    let hour: Int
    let weather: WeatherData
    
    var timeString: String {
        let hour = (hour + 8) % 24
        if hour == 0 { return "12 AM" }
        if hour < 12 { return "\(hour) AM" }
        if hour == 12 { return "12 PM" }
        return "\(hour - 12) PM"
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(timeString)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Image(systemName: weather.condition.icon)
                .font(.title2)
                .foregroundColor(.white)
            
            Text("\(weather.temperature + (hour % 5) - 2)°")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("\(hour % 10)%")
                .font(.caption2)
                .foregroundColor(.blue.opacity(0.7))
        }
        .frame(width: 70, height: 120)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Weekly View
struct WeeklyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("7-DAY FORECAST")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                
                VStack(spacing: 15) {
                    ForEach(0..<7) { day in
                        WeeklyRow(day: day)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 20)
            .padding(.bottom, 80)
        }
    }
}

// MARK: - Weekly Row
struct WeeklyRow: View {
    let day: Int
    
    var dayName: String {
        let date = Calendar.current.date(byAdding: .day, value: day, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack {
            Text(day == 0 ? "Today" : dayName)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 100, alignment: .leading)
            
            Spacer()
            
            Image(systemName: "sun.max.fill")
                .foregroundColor(.yellow)
            
            Spacer()
            
            HStack {
                Text("\(25)°")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("/")
                    .foregroundColor(.white.opacity(0.5))
                
                Text("\(18)°")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Precipitation chance
            HStack(spacing: 4) {
                Image(systemName: "drop")
                    .font(.caption)
                Text("\(day * 10)%")
                    .font(.caption)
            }
            .foregroundColor(.blue)
            .frame(width: 50)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Details View
struct DetailsView: View {
    let weather: WeatherData
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                DetailCard(title: "Feels Like", value: "\(weather.feelsLike)°", icon: "thermometer")
                DetailCard(title: "Humidity", value: "\(weather.humidity)%", icon: "humidity")
                DetailCard(title: "Wind", value: "\(weather.windSpeed) mph", icon: "wind")
                DetailCard(title: "Pressure", value: "1012 mb", icon: "barometer")
                DetailCard(title: "UV Index", value: "4", icon: "sun.max")
                DetailCard(title: "Dew Point", value: "\(weather.feelsLike - 2)°", icon: "drop")
                DetailCard(title: "Visibility", value: "10 mi", icon: "eye")
                DetailCard(title: "Cloud Cover", value: "\(Int.random(in: 0...100))%", icon: "cloud")
            }
            .padding()
            .padding(.bottom, 80)
        }
    }
}

// MARK: - Detail Card
struct DetailCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Map View
struct MapView: View {
    let weather: WeatherData
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(coordinateRegion: $region)
                .ignoresSafeArea()
            
            Text("PRECIPITATION MAP")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                .padding()
        }
        .padding(.bottom, 80)
    }
}

// MARK: - Search View
struct SearchView: View {
    let onSelect: (String) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    let popularCities = ["New York", "London", "Tokyo", "Paris", "Sydney", "Dubai", "Singapore", "Hong Kong", "Los Angeles", "Chicago"]
    
    var filteredCities: [String] {
        if searchText.isEmpty {
            return popularCities
        } else {
            return popularCities.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("POPULAR CITIES") {
                    ForEach(filteredCities, id: \.self) { city in
                        Button(action: {
                            onSelect(city)
                            dismiss()
                        }) {
                            HStack {
                                Text(city)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "location.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                if !searchText.isEmpty && !popularCities.contains(searchText) {
                    Section("SEARCH RESULT") {
                        Button(action: {
                            onSelect(searchText)
                            dismiss()
                        }) {
                            HStack {
                                Text("Search for \"\(searchText)\"")
                                    .foregroundColor(.blue)
                                Spacer()
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search for a city")
            .navigationTitle("Search City")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    let tabs = [
        ("sun.max.fill", "Today"),
        ("clock.fill", "Hourly"),
        ("calendar", "Weekly"),
        ("list.bullet", "Details"),
        ("map.fill", "Map")
    ]
    
    var body: some View {
        HStack {
            ForEach(0..<tabs.count, id: \.self) { index in
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: tabs[index].0)
                        .font(.system(size: 20))
                        .foregroundColor(selectedTab == index ? .white : .white.opacity(0.5))
                    
                    Text(tabs[index].1)
                        .font(.system(size: 10))
                        .foregroundColor(selectedTab == index ? .white : .white.opacity(0.5))
                }
                .onTapGesture {
                    withAnimation { selectedTab = index }
                }
                Spacer()
            }
        }
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 20, y: -5)
        )
        .padding(.horizontal)
    }
}

// MARK: - Weather Condition Extension
extension WeatherCondition {
    var gradientColors: [Color] {
        switch self {
        case .sunny:
            return [Color(red: 0.2, green: 0.6, blue: 0.9), Color(red: 0.6, green: 0.8, blue: 1.0)]
        case .cloudy, .partlyCloudy:
            return [Color(red: 0.3, green: 0.4, blue: 0.6), Color(red: 0.5, green: 0.6, blue: 0.8)]
        case .rainy:
            return [Color(red: 0.1, green: 0.2, blue: 0.4), Color(red: 0.3, green: 0.4, blue: 0.6)]
        case .snowy:
            return [Color(red: 0.4, green: 0.5, blue: 0.7), Color(red: 0.6, green: 0.7, blue: 0.9)]
        }
    }
}

#Preview {
    ContentView()
}
