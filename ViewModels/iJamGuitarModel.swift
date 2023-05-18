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
    
    /// This method sets all needed values for Tuning identified by tuningName
    /// and adds the new compled Tuning to the appState.
    /// It should ONLY be callled on the initial launch to build the appState from iJamGuitarModel.xcaDataModel,
    /// which is then used by iJamGuitarModel.
    /// - Parameters:
    ///   - appState: appState from .xcaDataModel
    ///   - tuning: tuning from appState
    ///   - tuningName: name of this Tuning
    ///   - openIndices: represents each Strings (open position)  index into the noteNames Array
    ///   - noteNames: noteNames is an array of the noteNames
    ///   - chordLibraryPath: pathName for this Tuning's chords Dictionary
    ///   - chordGroupsPath: pathName for this Tuning's chordGroups Dictionary
    func setupTuning(appState: AppState,
                     tuning: Tuning,
                     tuningName: String,
                     openIndices: String,
                     noteNames: String,
                     chordLibraryPath: String,
                     chordGroupsPath: String) {
        tuning.name = tuningName
        tuning.openNoteIndices = openIndices
        tuning.stringNoteNames = noteNames
        
        if let path = Bundle.main.path(forResource: chordLibraryPath, ofType: "plist"),
           let thisChordGroupChordDictionary = NSDictionary(contentsOfFile: path) as? [String: String] {
            let chordSet:NSSet = convertToSetOfChords(chordDictionary: thisChordGroupChordDictionary, parentTuning: tuning)
            tuning.addToChords(chordSet)
            
            if let path = Bundle.main.path(forResource: chordGroupsPath, ofType: "plist"),
                let thisChordGroupsDict = NSDictionary(contentsOfFile: path) as? [String: String] {
                let chordGroupSet:NSSet = convertToSetOfChordGroups(dict: thisChordGroupsDict, parentTuning: tuning)
                tuning.addToChordGroups(chordGroupSet)
            }
        }
        appState.addToTunings(tuning)
    }
    
    /// This method should ONLY be called on initial launch of app
    /// It populated the appState with 3 different tunings and
    /// sets initial values for:
    /// capoPosition
    /// isMuted
    /// volumeLevel
    /// activeTuning
    /// eachTunings activeChordGroup
    /// each chordGroups activeChord
    func loadDataModelFromPListsIntoPersistentStore() {
        // populate our initial dataModel from Plists
        let appState = AppState(context: context)

        // Standard Tuning
        let standardTuning = Tuning(context: context)
        setupTuning(appState: appState,
                    tuning: standardTuning,
                    tuningName: "Standard",
                    openIndices: "4-9-14-19-23-28",
                    noteNames: "E-A-D-G-B-E",
                    chordLibraryPath: "StandardTuning_ChordLibrary",
                    chordGroupsPath: "StandardTuningChordGroups")
        
        // Drop-D Tuning
        let dropDTuning = Tuning(context: context)
        setupTuning(appState: appState,
                    tuning: dropDTuning,
                    tuningName: "Drop D",
                    openIndices: "2-9-14-19-23-28",
                    noteNames: "D-A-D-G-B-E",
                    chordLibraryPath: "DropD_ChordLibrary",
                    chordGroupsPath: "DropDTuningChordGroups")
        
        // Open D Tuning
        let openDTuning = Tuning(context: context)
        setupTuning(appState: appState,
                    tuning: openDTuning,
                    tuningName: "Open D",
                    openIndices: "2-9-14-18-21-26",
                    noteNames: "D-A-D-F#-A-D",
                    chordLibraryPath: "OpenD_ChordLibrary",
                    chordGroupsPath: "OpenDTuningChordGroups")
        
        // remainder of appState
        appState.activeTuning = standardTuning
        appState.capoPosition = 0
        appState.isMuted = false
        appState.volumeLevel = NSDecimalNumber(value: kDefaultVolume)
        appState.activeTuning = standardTuning
        
        saveContext(context: context)
    }
    
    /// Creates and returns a NSSet of Chords available to parentTuning
    /// - Parameters:
    ///   - chordDictionary: dictionary of <chordName, fretIndicesString>
    ///   - parentTuning: the Tuning to which this set of Chords belongs
    /// - Returns: NSSet of Chord items
    func convertToSetOfChords(chordDictionary: Dictionary<String,String>, parentTuning: Tuning) -> NSSet {
        // create a NSMutableSet of Chord managed Objects
        let chordsSet = NSMutableSet()
        
        for entry in chordDictionary {
            let chord       = Chord(context:context)
            chord.name      = entry.key
            chord.fretMap   = entry.value
            chord.tuning    = parentTuning
            chordsSet.add(chord)
        }
        
        return chordsSet
    }

    func convertToSetOfChordGroups(dict: Dictionary<String,String>, parentTuning: Tuning) -> NSSet {
        // build NSMutableSet of ChordGroups
        let chordGroupsSet = NSMutableSet()
        var activeChordGroupIsSet = false
        
        for entry in dict {
            // create new group
            let chordGroup                  = ChordGroup(context: self.context)
            chordGroup.name                 = entry.key
            chordGroup.availableChordNames  = entry.value
            chordGroup.availableChords      = setGroupsChords(chordGroup: chordGroup, tuning: parentTuning)
            chordGroup.tuning               = parentTuning
            chordGroupsSet.add(chordGroup)
            if activeChordGroupIsSet == false {
                parentTuning.activeChordGroup = chordGroup
                activeChordGroupIsSet = true
            }
        }
        
        return chordGroupsSet
    }
    
    func setGroupsChords(chordGroup: ChordGroup?, tuning: Tuning?) -> NSMutableSet {
        let chordGroupSet = NSMutableSet()
        var activeChordIsSet = false
        if let chordNames = chordGroup?.availableChordNames?.components(separatedBy: "-") {
            for chordName in chordNames {
                if let chord = getChord(name: chordName, parentTuning: tuning) {
                    chordGroupSet.add(chord)
                    if activeChordIsSet == false {
                        chordGroup?.activeChord = chord
                        activeChordIsSet = true
                    }
                }
            }
        }
        
        return chordGroupSet
    }
    
    func getChord(name: String, parentTuning: Tuning?) -> Chord? {
        if let chordArray: [Chord] = parentTuning?.chords?.allObjects as? [Chord] {
            for chord in chordArray {
                if chord.name == name {
                    return chord
                }
            }
        }
        
        return nil
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
