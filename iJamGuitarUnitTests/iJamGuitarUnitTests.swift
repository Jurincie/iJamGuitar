//
//  iJamGuitarUnitTests.swift
//  IJAM_2022UnitTests
//
//  Created by Ron Jurincie on 4/8/23.
//

import XCTest
import SwiftUI
import AVFAudio

@testable import iJamGuitar

final class iJamViewModelTests: XCTestCase {
    // Given
    let stringsVM = StringsViewModel()
    let model = iJamGuitarModel()
    let tooBig = 20

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_iJamViewModel_getAvailableChordNames_returnsArrayOfTenStrings() {
        // When:
        let chordNameArray: [String] = model.getAvailableChordNames(activeChordGroup: model.activeChordGroup)
            
        // Then:
        XCTAssertEqual(chordNameArray.count, 10)
    }
   
    func test_StringsViewModel_noteNamesArray_shouldHaveFortyTwoElements() {
        XCTAssertEqual(stringsVM.noteNamesArray.count, 42)
    }
    
    func test_iJamGuitarModel_Tunings_ChordsMeetRequirements() {
        
        if let allTunings = model.appState?.tunings {
            if let tunings = Array(allTunings) as? [Tuning] {
                for tuning in tunings {
                    
                    for chord in tuning.chords! {
                        if let thisChord = chord as? Chord {
                            let meetsRequirements = doesChordMeetRequirements(thisChord)
                            XCTAssertEqual(meetsRequirements, true)
                        }
                    }
                }
            }
        }
    }
        
    func test_StringsViewModel_formerZone_shouldInitializeToNegativeOne () {
        // When
        let zone = stringsVM.formerZone
        
        // Then
        XCTAssertEqual(zone, -1)
    }
    
    func test_StringsViewModel_audioPlayerArray_ShouldHaveSixAudioPlayers() {
        // When
        XCTAssertNotNil(stringsVM.audioPlayerArray)
        XCTAssertEqual(stringsVM.audioPlayerArray.count, 6)
        
        // Then
        var thisAudioPlayer: AVAudioPlayer?
        
        for _ in 0...30 {
            thisAudioPlayer = stringsVM.audioPlayerArray[Int.random(in: 0..<6)]
            XCTAssertTrue(((thisAudioPlayer?.isKind(of: AVAudioPlayer.self)) != nil))
        }
    }
    
    func test_StringsViewModel_thisZone_shouldInitializeToNegativeOne () {
        // When
        let zone = stringsVM.formerZone

        // Then
        XCTAssertEqual(zone, -1)
    }
    
    func getSpan(fretMap: String) -> Int {
        var maxFret: Int = 0
        var minFret: Int = tooBig
        
        for char in fretMap {
            if char != "x" && char != "0" {
                let fret = model.getFretFromChar(char)
                maxFret = max(maxFret, fret)
                minFret = min(minFret, fret)
            }
        }
        
        if minFret >= tooBig {
            minFret = 0
        }
        
        return maxFret - minFret
    }
    
    func doesChordMeetRequirements(_ chord: Chord) -> Bool {
        if chord.fretMap?.count != 6 {
            return false
        }
        let span = getSpan(fretMap: chord.fretMap ?? "119911")
        if span < 0 || span > 5 {
            return false
        }
    
        return true
    }
}
