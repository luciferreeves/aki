//
//  akiApp.swift
//  aki
//
//  Created by Conrad Reeves on 10/30/24.
//

import SwiftUI

@main
struct akiApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 1024, maxWidth: .infinity, minHeight: 768, maxHeight: .infinity)
        }
        .windowResizability(.contentSize)
    }
}
