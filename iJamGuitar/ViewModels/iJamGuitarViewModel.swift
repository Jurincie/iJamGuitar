//
//  iJamGuitarViewModel.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/24/23.
//

import Foundation
import CoreData
import AVFoundation

class iJamGuitarViewModel: ObservableObject {
    private (set) var context = PersistenceController.shared.container.viewContext
    @Published var showAudioNotAvailableAlert: Bool = false
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
            minimumFret = getinimumDisplayedFret()
        }
    }
    
    /// This var calculates the lowest displayed fret above the nut for the activeChord in the activeChordGroup in the activeTuning
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

    init() {
        appState                = getAppState()
        activeTuningName        = appState?.activeTuning?.name ?? "XXX"
        activeChordGroup        = appState?.activeTuning?.activeChordGroup
        activeChordGroupName    = activeChordGroup?.name ?? "xxx"
        selectedIndex           = getSelectedChordButtonIndex()
        activeChord             = activeChordGroup?.activeChord
        minimumFret             = getinimumDisplayedFret()
        fretIndexMap            = getFretIndexMap(chord: activeChord)
        availableChords         = getAvailableChords(activeChordGroup: activeChordGroup, activeTuning: activeTuning)
        
        // if another app is using AudioPlayer -> show alert
        showAudioNotAvailableAlert = AVAudioSession.sharedInstance().isOtherAudioPlaying
        
        if let muted = appState?.isMuted {
            isMuted = muted
        }
    }
}

