//
//  iJamGuitarModel.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/24/23.
//

import SwiftUI
import CoreData

class iJamGuitarModel {
    let context = PersistenceController.shared.container.viewContext
    let kDefaultVolume = 5.0
    
    init() {
        // ONLY BUILD the dataModel from .plists once, on intial launch
        let request = NSFetchRequest<AppState>(entityName: "AppState")
        let appState: AppState?
        do {
            let appStates: [AppState] = try context.fetch(request)
            appState = appStates.first
            if appState == nil {
                loadDataModelFromPListsIntoPersistentStore()
            }
        } catch {
            let error = error as NSError
            debugPrint("Error getting AppState \(error)")
        }
    }
    
    func setupTuning(appState: AppState,
                     tuning: Tuning,
                     name: String,
                     openIndices: String,
                     noteNames: String,
                     resName1: String,
                     resName2: String) {
        tuning.name = name
        tuning.openNoteIndices = openIndices
        tuning.stringNoteNames = noteNames
        
        if let path = Bundle.main.path(forResource: resName1, ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            let chordSet:NSSet = convertToSetOfChords(dict: dict, parentTuning: tuning)
            tuning.addToChords(chordSet)
            
            if let path = Bundle.main.path(forResource: resName2, ofType: "plist"),
                let thisChordGroupsDict = NSDictionary(contentsOfFile: path) as? [String: String] {
                let chordGroupSet:NSSet = convertToSetOfChordGroups(dict: thisChordGroupsDict, parentTuning: tuning)
                tuning.addToChordGroups(chordGroupSet)
            }
        }
        appState.addToTunings(tuning)
    }
    
    func loadDataModelFromPListsIntoPersistentStore() {
        // populate our initial dataModel from Plists
        let appState = AppState(context: context)

        // Standard Tuning
        let standardTuning = Tuning(context: context)
        setupTuning(appState: appState,
                    tuning: standardTuning,
                    name: "Standard",
                    openIndices: "4-9-14-19-23-28",
                    noteNames: "E-A-D-G-B-E",
                    resName1: "StandardTuning_ChordLibrary",
                    resName2: "StandardTuningChordGroups")
        
        // Drop-D Tuning
        let dropDTuning = Tuning(context: context)
        setupTuning(appState: appState,
                    tuning: dropDTuning,
                    name: "Drop D",
                    openIndices: "2-9-14-19-23-28",
                    noteNames: "D-A-D-G-B-E",
                    resName1: "DropD_ChordLibrary",
                    resName2: "DropDTuningChordGroups")
        
        // Open D Tuning
        let openDTuning = Tuning(context: context)
        setupTuning(appState: appState,
                    tuning: openDTuning,
                    name: "Open D",
                    openIndices: "2-9-14-18-21-26",
                    noteNames: "D-A-D-F#-A-D",
                    resName1: "OpenD_ChordLibrary",
                    resName2: "OpenDTuningChordGroups")
        
        // remainder of appState
        appState.activeTuning = standardTuning
        appState.capoPosition = 0
        appState.isMuted = false
        appState.volumeLevel = NSDecimalNumber(value: kDefaultVolume)
        appState.activeTuning = standardTuning
        saveContext(context: context)
    }
}

// MARK: - Save Core Data Context
func saveContext(context: NSManagedObjectContext) {
    if context.hasChanges {
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
