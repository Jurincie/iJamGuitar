//
//  IJamGuitarViewModelExtension.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/2/23.
//

import Foundation
import CoreData

extension iJamGuitarModel
{
    /// This method takes a name associated with appState.Tunings names
    /// and returns an associated Tuning if able, otherwise is return nil
    /// - Parameter name: name-> The name selected by user in Tuning Picker
    /// - Returns:Tuning associated with Name
    func getTuning(name: String) -> Tuning? {
        var newTuning: Tuning? = nil
        if let tunings = appState?.tunings {
            for case let tuning as Tuning in tunings {
                if tuning.name == name {
                    newTuning = tuning
                    break
                }
            }
        }
        return newTuning
    }
   
    
    /// - Parameter newTuning: newTuning
    /// /// Description: When user selects NEW Tuning, we need to set:
    /// ///activeTuning,  appState?.activeTUNINGm activeChordGroup and appState?.activeChordGroup, activeChordGroupNamem availableChords
    /// /// fretIndexMap and selectedIndex based on the activeChord for this Tuning
    /// /// We save new appState members here
    /// /// Warning:Must set activeChordGroup prior to setting activeChordGroupName
    ///
    func setNewActiveTuning(newTuning: Tuning) {
        // set activeTuning in model and dataModel
        activeTuning = newTuning
        appState?.activeTuning = newTuning
        activeChordGroup = newTuning.activeChordGroup
        activeChordGroupName = activeChordGroup?.name ?? ""
        appState?.activeTuning?.activeChordGroup = newTuning.activeChordGroup
        availableChords = getAvailableChords(activeChordGroup: activeChordGroup, activeTuning: activeTuning)
        fretIndexMap = getFretIndexMap(chord: activeChordGroup?.activeChord)
        selectedChordIndex = getSelectedChordButtonIndex()
        try? context.save()
    }
    
    ///  This method instantiates and returns a new ChordGroup based upon the name parameter.
    ///     if no such ChordGroup with that name exists, this method returns nil
    /// - Parameter name: name-> The name selected by user in ChordGroup Picker
    /// - Returns: Optional(ChordGroup)
    func getChordGroup(name: String) -> ChordGroup? {
        var newChordGroup: ChordGroup? = nil
        
        if let chordGroups = activeTuning?.chordGroups {
            for case let chordGroup as ChordGroup in chordGroups {
                if chordGroup.name == name {
                    newChordGroup = chordGroup
                    break
                }
            }
        }
        return newChordGroup
    }
    
    ///  This method sets the newly instantiated newChordGroup as the appState.activeChordGroup.
    ///  Then sets the appState.availableChords to the chords associated with this newChordGroup.
    ///  Then sets the appState.activeChord to the newChordGroup.activeChord
    ///  Then sets the appState.selectedIndex via getSelectedChordButtonIndex()
    ///  Then saves the context.
    /// - Parameter newChordGroup: a recently instantiated newChordGroup
    func setActiveChordGroup(newChordGroup: ChordGroup) {
        activeChordGroup = newChordGroup
        availableChords = getAvailableChords(activeChordGroup: newChordGroup, activeTuning: activeTuning)
        appState?.activeTuning?.activeChordGroup = newChordGroup
        activeChord = newChordGroup.activeChord
        selectedChordIndex = getSelectedChordButtonIndex()
        try? context.save()
    }
    
    /// This method returns an array of names associated with available appState.Tunings
    /// - Returns: an Array of Strings containing the names of the available Tunings.
    func getTuningNames() -> [String] {
        var tuningNames: [String] = []
        if let tuningsArray: [Tuning] = self.appState?.tunings?.allObjects as? [Tuning] {
            for tuning in tuningsArray {
                tuningNames.append(tuning.name ?? "BadName")
            }
        }
        return tuningNames
    }
    
    /// This method returns an array of names associated with appState.activeTuning.chordGroup.names
    /// - Returns: an Array of Strings containing the available chordGroup names for appState.activeTuning.
    func getChordGroupNames() -> [String] {
        var chordGroupNames: [String] = []
        
        if let chordGroupArray: [ChordGroup] = self.appState?.activeTuning?.chordGroups?.allObjects as? [ChordGroup] {
            for chordGroup in chordGroupArray {
                chordGroupNames.append(chordGroup.name ?? "")
            }
        }
        return chordGroupNames
    }
  
    func getSelectedChordButtonIndex() -> Int {
        if let activeChord = activeChord,
           let activeChordIndex = availableChords.firstIndex(of: activeChord) {
            return activeChordIndex
        }
        return 0
    }
    
    // Must acccept both: "xx0212" "9ABCAA" and "320003"
    func getFretFromChar(_ char: Character) -> Int {
        switch char {
        case "A": return 10
        case "B": return 11
        case "C": return 12
        default: return char.wholeNumberValue ?? -1
        }
    }
    
    func getFretIndexMap(chord: Chord?) -> [Int] {
        var fretsArray : [Int] = []
        if let fretMap = chord?.fretMap {
            for char in fretMap {
                fretsArray.append(getFretFromChar(char))
            }
        }
        return fretsArray
    }
    
    func getAppState() -> AppState? {
        var appState: AppState?
        let request = NSFetchRequest<AppState>(entityName: "AppState")
        do {
            let appStates: [AppState] = try context.fetch(request)
            appState = appStates.first
        } catch {
            let error = error as NSError
            debugPrint("Error getting AppState \(error)")
        }
        return appState
    }
    
    /// Gets chord names for this chordGroup
    /// - Parameter activeChordGroup: the currently active chordGroup
    /// - Returns: array of chord names associated with activeChordGroup argument
    func getAvailableChordNames(activeChordGroup: ChordGroup?) -> [String] {
        if var availableChordNames: [String] = activeChordGroup?.availableChordNames?.components(separatedBy: ["-"]) {
            if availableChordNames.count == 10 {
                return availableChordNames
            }
            for _ in availableChordNames.count...9 {
                availableChordNames.append("NoChord")
            }
            return availableChordNames
        }
        return []
    }
    
    /// Gets an array of chords that belong to the activeChordGroup in the activeTuning
    /// - Parameters:
    ///   - activeChordGroup: optional(activeChordGroup)
    ///   - activeTuning: optional(activeTuning
    /// - Returns: array of chords associated with activeChordGroup for activeTuning or empty array if anything goes wrong
    func getAvailableChords(activeChordGroup: ChordGroup?, activeTuning: Tuning?) -> [Chord] {
        var availableChords: [Chord] = []
        if let chordNames = activeChordGroup?.availableChordNames?.components(separatedBy: "-"),
           let activeTuning = activeTuning {
            for chordName in chordNames {
                if let chord = getChord(name: chordName, tuning: activeTuning) {
                    availableChords.append(chord)
                }
            }
        }
        return availableChords
    }
    
    /// Gets the chord associated with the name argument for the tuning argumen
    /// - Parameters:
    ///   - name: the name of the new chord
    ///   - tuning: the activeTuning
    /// -   Returns: optional(Chord)
    ///             which is nil if no chord with name in arg #1 exists in the optional(Tuning) in arg #2
    ///             otherwise it returns the new chord for the optional(Tuning) in arg #2 if tuning exists
    func getChord(name: String, tuning: Tuning?) -> Chord? {
        if let chordArray: [Chord] = tuning?.chords?.allObjects as? [Chord] {
            for chord in chordArray {
                if chord.name == name {
                    return chord
                }
            }
        }
        return nil
    }
    
    /// This function calculates and returns the lowest displayed fret above the nut for the activeChord in the activeChordGroup in the activeTuning
    /// - Returns: Int of the lowest displayed fret above the nut
    /// Note: must be > the nut Int
    func getinimumDisplayedFret() -> Int {
        guard let fretChars = activeChord?.fretMap else { return 0 }
        var highest = 0
        var thisFretVal = 0
        
        for char in fretChars {
            switch char {
                // span does NOT include open string nor muted strings
            case "x":
                break
            case "A":
                thisFretVal = 11
            case "B":
                thisFretVal = 12
            case "C":
                thisFretVal = 13
            case "D":
                thisFretVal = 14
            default:
                if let intValue = char.wholeNumberValue {
                    thisFretVal = intValue
                } else {
                    thisFretVal = 0
                }
            }
            highest = max(highest, thisFretVal)
        }
        
        return highest < 6 ? 1 : max(1, highest - 4)
    }
}
