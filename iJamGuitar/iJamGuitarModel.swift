//
//  iJamGuitarModel.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/24/23.
//

import SwiftUI
import CoreData
import AVFAudio

class iJamGuitarModel: ObservableObject {
    let context = PersistenceController.shared.container.viewContext
    let kDefaultVolume = 5.0
    @Published var presentVolumeAlert = false
    @Published var showAudioPlayerInUseAlert = false
    @Published var showAudioPlayerErrorAlert = false
    @Published var appState: AppState?
    @Published var activeTuning: Tuning?
    @Published var capoPosition: Int = 0
    @Published var showAudioNotAvailableAlert: Bool = false
    @Published var activeChordGroup: ChordGroup?
    @Published var isMuted = false
    @Published var volumeLevel = 5.0
    @Published var selectedChordIndex: Int = 0      // index into the availableChords for activeChordGroup
    @Published var savedVolumeLevel = 5.0           // allow us to return to level when volume set to zero via "mute"
    @Published var fretIndexMap: [Int] = []         // fretIndexMap of current (Chord with changes) disregarding capo position
    @Published var minimumFret: Int = 0             // lowest fret excluding open
    @Published var availableChords: [Chord] = []    // array of available chords for activeChordGroup
    @Published var activeTuningName: String = "" {
        didSet {
            if let newTuning = getTuning(name: activeTuningName) {
                setNewActiveTuning(newTuning: newTuning)
            }
        }
    }
    @Published var activeChordGroupName: String = ""
    {
        didSet {
            if let newChordGroup = getChordGroup(name: activeChordGroupName) {
                setActiveChordGroup(newChordGroup: newChordGroup)
            }
        }
    }
    @Published var activeChord: Chord? {
        didSet {
            appState?.activeTuning?.activeChordGroup?.activeChord = activeChord
            fretIndexMap = getFretIndexMap(chord: activeChord)
            minimumFret = getinimumDisplayedFret()
        }
    }
    
    static let shared = iJamGuitarModel()
    
    ///  ONLY Call LoadDatatModelFromPLists to build our data model, on initial launch
    init() {
        let request = NSFetchRequest<AppState>(entityName: "AppState")
        do {
            let appStates: [AppState] = try context.fetch(request)
            appState = appStates.first
            if appState == nil {
                loadDataModelFromPLists()
            }
            
            setupModel()
            
            // if another app is using AudioPlayer -> show alert
            showAudioNotAvailableAlert = AVAudioSession.sharedInstance().isOtherAudioPlaying
        } catch {
            let error = error as NSError
            debugPrint("Error getting AppState \(error)")
            fatalError()
        }
    }
    
    private func setupModel() {
        availableChords = getAvailableChords(activeChordGroup: appState?.activeTuning?.activeChordGroup,
                                             activeTuning: appState?.activeTuning)
        fretIndexMap = getFretIndexMap(chord: appState?.activeTuning?.activeChordGroup?.activeChord)
        selectedChordIndex = getSelectedChordIndex()
        // these are convenience properties
        activeTuning            = appState?.activeTuning
        activeTuningName        = activeTuning?.name ?? ""
        activeChordGroup        = activeTuning?.activeChordGroup
        activeChordGroupName    = activeChordGroup?.name ?? ""
        activeChord             = activeChordGroup?.activeChord
    }
    
    func getSelectedChordIndex() -> Int {
        var selectedChordIndex = 0
        
        for chord in availableChords {
            if chord == appState?.activeTuning?.activeChordGroup?.activeChord {
                break
            }
            selectedChordIndex += 1
        }
        selectedChordIndex = min(availableChords.count - 1, selectedChordIndex)
        
        return selectedChordIndex
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
    /// It populated the appState with tunings specified in .plist and sets initial values for:
    /// capoPosition
    /// isMuted
    /// volumeLevel
    /// activeTuning
    /// eachTunings activeChordGroup
    /// each chordGroups activeChord
    func loadDataModelFromPLists() {
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
    
    /// This method builds NSMutableSet of ChordGroups for this parentTuning
    /// - Parameters:
    ///   - dict: [String: String]  dictionary of [ChordGroup.name, chordNamesString] which are used to build returned chordGroupsSet
    ///   - parentTuning: the parentTuning to which this group belongs
    /// - Returns: NSMutableSet of ChordGroups
    func convertToSetOfChordGroups(dict: Dictionary<String,String>, parentTuning: Tuning) -> NSSet {
        let chordGroupsSet = NSMutableSet()
        var activeChordGroupIsSet = false
        
        for entry in dict {
            // create new ChordGroup
            let chordGroup                  = ChordGroup(context: self.context)
            chordGroup.name                 = entry.key
            chordGroup.availableChordNames  = entry.value
            chordGroup.availableChords      = getGroupsChords(chordGroup: chordGroup, parentTuning: parentTuning)
            chordGroup.tuning               = parentTuning
            if activeChordGroupIsSet == false {
                parentTuning.activeChordGroup = chordGroup
                activeChordGroupIsSet = true
            }
            chordGroupsSet.add(chordGroup)
        }
        
        return chordGroupsSet
    }
    
    /// This method builds a NSMutableSet of chordGroups available Chords
    /// - Parameters:
    ///   - chordGroup: Optional ChordGroup
    ///   - parentTuning: Optional Tuning to which this group belongs
    /// - Returns: NSMutableSet of this ChoreGroups Chords
    func getGroupsChords(chordGroup: ChordGroup?, parentTuning: Tuning?) -> NSMutableSet {
        let thisGroupsChords = NSMutableSet()
        var activeChordIsSet = false
        if let chordNames = chordGroup?.availableChordNames?.components(separatedBy: "-") {
            for chordName in chordNames {
                if let chord = getChord(name: chordName, parentTuning: parentTuning) {
                    thisGroupsChords.add(chord)
                    if activeChordIsSet == false {
                        chordGroup?.activeChord = chord
                        activeChordIsSet = true
                    }
                }
            }
        }
        
        return thisGroupsChords
    }
    
    /// This method returns the Chord specified by name for the parentTuning
    /// - Parameters:
    ///   - name: name of the chord in this Tuning
    ///   - parentTuning: the Tuning to which this chord belongs
    /// - Returns: Chord specified by name in parentTuning
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
            fatalError("Unresolved error \(nserror), \(nserror.underlyingErrors)")
        }
    }
}
