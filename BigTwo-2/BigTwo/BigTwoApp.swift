//
//  BigTwoApp.swift
//  BigTwo
//
//  Created by student on 12/12/2023.
//

import SwiftUI

@main
struct BigTwoApp: App {
    var body: some Scene {
        WindowGroup {
            let game = BigTwoViewModel()
            ContentView(viewModel: game)
        }
    }
}
