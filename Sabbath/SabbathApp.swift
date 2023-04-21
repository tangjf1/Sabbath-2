//
//  SabbathApp.swift
//  Sabbath
//
//  Created by Jasmine on 4/4/23.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct SabbathApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userVM = UserViewModel()
    @StateObject var locationManager = LocationManager()
    @StateObject var sabbathVM = SabbathViewModel()
    @StateObject var weatherVM = WeatherViewModel()
    var body: some Scene {
        WindowGroup {
            NavigationView {
                LoginView()
                    .environmentObject(userVM)
                    .environmentObject(locationManager)
                    .environmentObject(sabbathVM)
                    .environmentObject(weatherVM)
            }
        }
    }
}

