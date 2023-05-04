//
//  iJamGuitarApp.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 5/4/23.
//

import SwiftUI

@main
struct iJamGuitarApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
