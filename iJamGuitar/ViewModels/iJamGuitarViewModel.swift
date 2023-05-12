//
//  iJamGuitarViewModel.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/24/23.
//

import Foundation
import CoreData

class iJamGuitarViewModel: ObservableObject {
    private (set) var context = PersistenceController.shared.container.viewContext
    
    @Published var appState: AppState?
    @Published var activeTuning: Tuning?
    @Published var activeChordGroup: ChordGroup?
    @Published var capoPosition: Int = 0
    @Published var isMuted = false
    @Published var volumeLevel = 5.0
    @Published var savedVolumeLevel = 5.0           // allow us to return to level when volume set to zero via "mute"
    @Published var fretIndexMap: [Int] = []         // fretIndexMap of current (Chord) disregarding capo position
    @Published var minimumFret: Int = 0             // lowest fret excluding open
    @Published var selectedIndex: Int = 0           // index into availableChords
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
            minimumFret = getMinDisplayedFret()
        }
    }

    init() {
        appState                = getAppState()
        activeTuningName        = appState?.activeTuning?.name ?? "XXX"
        activeChordGroup        = appState?.activeTuning?.activeChordGroup
        activeChordGroupName    = activeChordGroup?.name ?? "xxx"
        selectedIndex           = getSelectedChordButtonIndex()
        activeChord             = activeChordGroup?.activeChord
        minimumFret             = getMinDisplayedFret()
        fretIndexMap            = getFretIndexMap(chord: activeChord)
        availableChords         = getAvailableChords(activeChordGroup: activeChordGroup, activeTuning: activeTuning)
        
        if let muted = appState?.isMuted {
            isMuted = muted
        }
    }
}

