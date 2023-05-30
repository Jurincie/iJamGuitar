//
//  iJamGuitarApp.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 5/4/23.
//

import SwiftUI
import CoreData

@main
struct iJamGuitarApp: App {
    let persistenceController = PersistenceController.shared
//    let model = iJamGuitarModel()

    var body: some Scene {
        WindowGroup {
            // inject the view context into the ContentView and all its offspring
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

