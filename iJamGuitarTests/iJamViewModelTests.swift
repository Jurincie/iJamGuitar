//
//  iJamViewModelTests.swift
//  IJAM_2022UnitTests
//
//  Created by Ron Jurincie on 4/8/23.
//

import XCTest
import SwiftUI
import AVFAudio

@testable import iJamGuitar

final class iJamViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_iJamViewModel_getAvailableChordNames_returnsArrayOfTenStrings() {
        // Given:
        let vm = iJamGuitarViewModel()
        
        // When:
        let chordNameArray: [String] = vm.getAvailableChordNames(activeChordGroup: vm.activeChordGroup)
            
        // Then:
        XCTAssertEqual(chordNameArray.count, 10)
    }
    
    func test_iJamViewModel_getAvailableChords_returnsArrayOfTenChords() {
        // Given:
        let vm = iJamGuitarViewModel()

        // When:
        let chords: [Chord] = vm.getAvailableChords(activeChordGroup: vm.activeChordGroup, activeTuning: vm.activeTuning)

        // Then:
        XCTAssertEqual(chords.count, 10)
    }
   
    func test_StringsViewModel_noteNamesArray_shouldHaveFortyTwoElements() {
        // Given
        let stringsVM = StringsViewModel()

        // When
        
        // Then
        XCTAssertEqual(stringsVM.noteNamesArray.count, 42)
    }
    
    func test_iJamViewModel_appStateActiveTuningName_equalsviewModelName() {
        // Given:
        
        let app = XCUIApplication()
        app.images["String4"]/*@START_MENU_TOKEN@*/.press(forDuration: 3.5);/*[[".tap()",".press(forDuration: 3.5);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.staticTexts["G"].tap()
        app.images["String6"].swipeRight()
        app.images["String1"]/*@START_MENU_TOKEN@*/.press(forDuration: 0.8);/*[[".tap()",".press(forDuration: 0.8);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        
        let stringareaviewImage = app.images["StringAreaView"]
        stringareaviewImage.swipeLeft()
        stringareaviewImage.swipeRight()
        let vm = iJamGuitarViewModel()
        
        // When:
        vm.activeTuningName = "Standard"
        
        // Then:
        XCTAssertEqual(vm.activeTuningName, vm.appState?.activeTuning?.name)
    }
    
    func test_iJamViewModel_Tunings_ChordsMeetRequirements() {
        // Given:
        let vm = iJamGuitarViewModel()
        let tooBig = 20
        
        if let allTunings = vm.appState?.tunings {
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
        
        func test_StringsViewModel_formerZone_shouldInitializeToNegativeOne () {
            // Given
            let stringsVM = StringsViewModel()
            
            // When
            let zone = stringsVM.formerZone
            
            // Then
            XCTAssertEqual(zone, -1)
        }
        
        func test_StringsViewModel_audioPlayerArray_ShouldHaveSixAudioPlayers() {
            // Given
            let stringsVM = StringsViewModel()
            
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
            // Given
            let stringsVM = StringsViewModel()
            
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
                    let fret = vm.getFretFromChar(char)
                    maxFret = max(maxFret, fret)
                    minFret = min(minFret, fret)
                }
            }
            if minFret == tooBig {
                minFret = 0
            }
            
            let span = maxFret - minFret
            
            return span
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
}
