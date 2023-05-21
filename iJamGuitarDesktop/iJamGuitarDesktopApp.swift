//
//  iJamGuitarDesktopApp.swift
//  iJamGuitarDesktop
//
//  Created by Ron Jurincie on 5/20/23.
//

import SwiftUI

@main
struct iJamGuitarDesktopApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
