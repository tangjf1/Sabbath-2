//
//  WeatherView.swift
//  Sabbath
//
//  Created by Jasmine on 4/19/23.
//

import SwiftUI

struct WeatherView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var weatherVM: WeatherViewModel
    @Binding var selectedDate: Date
    var lat: Double {
        return locationManager.location?.coordinate.latitude ?? 0.0
    }
    
    var lon: Double {
        return Double(locationManager.location?.coordinate.longitude ?? 0.0)
    }
    
    var weather: Daily {
        return weatherVM.dailyWeatherArray.first(where: {$0.id == selectedDate.getFullDateForWeather()}) ?? Daily()
    }
    
    var futureForecast: Bool {
        return (selectedDate.getFullDateForWeather() == Date().getFullDateForWeather()) || (selectedDate > Date())
    }
    var body: some View {
        HStack{
            Image(systemName: "\( weather.precipitation_sum > 0.01 ? "cloud.rain" : weather.temperature_2m_max > 60 ? "thermometer.sun" : weather.temperature_2m_max > 30 ? "thermometer" : weather.temperature_2m_max == -500.0 ? "cloud.sun" : "thermometer.snowflake" )")
            VStack (alignment: .leading){
                    Text("High: \( weather.temperature_2m_max == -500 ? "--" : String(format: "%.01f", weather.temperature_2m_max))°F Low: \(weather.temperature_2m_min == -500 ? "--" :  String(format: "%.01f", weather.temperature_2m_min))°F")
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                Text("Precipitation: \( weather.precipitation_sum == -500 ? "--" : "\(String(format: (futureForecast ? "%.0f" : "%.02f"), weather.precipitation_sum))\(futureForecast ? "%" : "in")")")
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .font(.caption2)
        }
        .onChange(of: selectedDate, perform: { newValue in
            if newValue + (60*60*24*7) < Date() {
                Task {
                    await weatherVM.getHistoricWeather(day: newValue, lat: lat, lon: lon)
                }
            } else if futureForecast {
                Task {
                    await weatherVM.getForecast(lat:lat, lon: lon)
                }
            }
        })
        .padding(.horizontal)
        .onAppear{
            if selectedDate + (60*60*24*7) < Date() {
                Task {
                    await weatherVM.getHistoricWeather(day: selectedDate, lat: lat, lon: lon)
                }
            }
             else if selectedDate.getFullDateForWeather() == Date().getFullDateForWeather() {
                Task {
                    await weatherVM.getForecast(lat:lat, lon: lon)
                }
            }
        }
    }
}

struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(selectedDate: .constant(Date()))
            .environmentObject(LocationManager())
            .environmentObject(WeatherViewModel())
    }
}
