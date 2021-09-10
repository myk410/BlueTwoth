//
//  BlueTwothApp.swift
//  BlueTwoth
//
//  Created by G. Michael Fortin Jr on 9/10/21.
//

import SwiftUI

@main
struct BlueTwothApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(CBModel())
        }
    }
}
