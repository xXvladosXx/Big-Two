//
//  BigTwoApp.swift
//  BigTwo
//
//  Created by student on 12/12/2023.
//

import SwiftUI

@main
struct BigTwoApp: App {
   @StateObject var appState = BigTwoViewModel.shared 
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView().id(appState.gameID)
        }
    }
}
