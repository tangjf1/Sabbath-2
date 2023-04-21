//
//  WeatherViewModel.swift
//  Sabbath
//
//  Created by Jasmine on 4/19/23.
//

import Foundation

@MainActor
class WeatherViewModel: ObservableObject {
    
    @Published var dailyWeatherArray: [Daily] = []
    
    @Published var urlStringForCoordinates = "https://api.weather.gov/points/42.3355,-71.1685"
    @Published var urlStringForForecast = "https://api.weather.gov/gridpoints/BOX/68,88/forecast"
    private struct Properties: Codable {
        var forecast: String
    }
    private struct ReturnedFromCoordinates: Codable {
        var properties: Properties
    }
    
    private struct Properties2: Codable {
        var periods: [Period]
    }
    private struct ReturnedFromForecast: Codable {
        var properties: Properties2
    }
    private struct Period: Codable {
        var number: Int
        var name: String
        var startTime: String
        var temperature: Int
        var probabilityOfPrecipitation: ProbPrecip
        var shortForecast: String
    }
    private struct ProbPrecip: Codable {
        var value: Int?
    }
    
    private struct ReturnedDaily: Codable {
        var time: [String]
        var temperature_2m_max: [Double?]
        var temperature_2m_min: [Double?]
        var precipitation_sum: [Double?]
    }
    private struct Returned: Codable {
        var daily: ReturnedDaily
    }
    
    @Published var urlString = "https://api.open-meteo.com/v1/forecast?latitude=?&longitude=?&daily=temperature_2m_max,temperature_2m_min,precipitation_sum&temperature_unit=fahrenheit&windspeed_unit=ms&precipitation_unit=inch&timezone=auto"
    
    @Published var weatherOneDay = Daily()
    
    func getHistoricWeather(day: Date, lat: Double, lon: Double) async {
        let date = day.getFullDateForWeather()
        urlString = "https://archive-api.open-meteo.com/v1/archive?latitude=\(lat)&longitude=\(lon)&start_date=\(date)&end_date=\(date)&daily=temperature_2m_max,temperature_2m_min,precipitation_sum&timezone=auto&temperature_unit=fahrenheit&windspeed_unit=ms&precipitation_unit=inch"
        
        print("🕸 We are accessing the url \(urlString)")
        
        // convert urlString to a special URL type
        guard let url = URL(string: urlString) else {
            print("😡 ERROR: Could not create a URL from \(urlString)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            // Try to decode JSON into our own data structure
            guard let returned = try? JSONDecoder().decode(Returned.self, from: data)
            else {
                print("😡 JSON ERROR: Could not decode returned JSON data")
                return
            }
            let weather = Daily(id: date, time: returned.daily.time[0], temperature_2m_max: returned.daily.temperature_2m_max[0] ?? -500.0, temperature_2m_min: returned.daily.temperature_2m_min[0] ?? -500.0, precipitation_sum: returned.daily.precipitation_sum[0] ?? -500.0)
            
            weatherOneDay = weather
            
            print(weather.time)
            print("Max Temp: \(weather.temperature_2m_max == -500.0 ? "unknown" : String(weather.temperature_2m_max))")
            print("Min Temp: \(weather.temperature_2m_min == -500.0 ? "unknown" : String(weather.temperature_2m_min))")
            print("Preciptation: \(weather.precipitation_sum == -500.0 ? "unknown" : String(weather.precipitation_sum))")
            
        } catch {
            print("😡 ERROR: Could not use URL at \(urlString) to get data and response ")
        }
        if weatherOneDay.id != nil {
            if let i = dailyWeatherArray.firstIndex(where: { $0.id == date}){
                dailyWeatherArray[i] = weatherOneDay
                print("updating weather entry for: \(weatherOneDay.id!)")
            } else {
                dailyWeatherArray.append(weatherOneDay)
                print("appending weather entry for: \(weatherOneDay.id!)")
            }
        }
    }
    func getForecast(lat: Double, lon: Double) async {
        urlStringForCoordinates = "https://api.weather.gov/points/\(lat),\(lon)"
        print("🕸 We are accessing the url \(urlStringForCoordinates)")
        // convert urlString to a special URL type
        guard let url = URL(string: urlStringForCoordinates) else {
            print("😡 ERROR: Could not create a URL from \(urlStringForCoordinates)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            // Try to decode JSON into our own data structure
            guard let returned = try? JSONDecoder().decode(ReturnedFromCoordinates.self, from: data)
            else {
                print("😡 JSON ERROR: Could not decode returned JSON data")
                return
            }
            urlStringForForecast = returned.properties.forecast
        } catch {
            print("😡 ERROR: Could not use URL at \(urlString) to get data and response ")
        }
        
        print("🕸 We are accessing the url \(urlStringForForecast)")
        // convert urlString to a special URL type
        guard let url2 = URL(string: urlStringForForecast) else {
            print("😡 ERROR: Could not create a URL from \(urlStringForForecast)")
            return
        }
        
        do {
            let (data2, _) = try await URLSession.shared.data(from: url2)
            // Try to decode JSON into our own data structure
            guard let returned2 = try? JSONDecoder().decode(ReturnedFromForecast.self, from: data2)
            else {
                print("😡 JSON ERROR: Could not decode returned JSON data")
                return
            }
            let periods = returned2.properties.periods
            var dayWeatherEntry = Daily()
            for period in periods {
                let date = period.startTime.components(separatedBy: "T")[0]
                if !period.name.lowercased().hasSuffix("night") {
                    dayWeatherEntry = Daily(id: date, time: date, temperature_2m_max: Double(period.temperature), precipitation_sum: Double(period.probabilityOfPrecipitation.value ?? 0))
                } else {
                    dayWeatherEntry.temperature_2m_min = Double(period.temperature)
                    if let i = dailyWeatherArray.firstIndex(where: { $0.id == date}){
                        dailyWeatherArray[i] = dayWeatherEntry
                        print("updating weather forecast for: \(dayWeatherEntry.id!)")
                    } else {
                        dailyWeatherArray.append(dayWeatherEntry)
                        print("appending weather forecast for: \(dayWeatherEntry.id!)")
                    }
                }
            }
        } catch {
            print("😡 ERROR: Could not use URL at \(urlStringForForecast) to get data and response ")
        }
    
    }
    
}
