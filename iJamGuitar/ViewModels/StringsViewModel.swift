//
//  StringsViewModel.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/24/23.
//

import Foundation
import SwiftUI
import AVFoundation
import CoreData

enum InitializeErrors: Error {
    case InitializeSoundsError
    case MissingResourseError
    case AVAudioSessionError
}

struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = CGRectZero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

class StringsViewModel: ObservableObject {
    @State var showAudioPlayerInUseAlert = false
    @State var showAudioPlayerErrorAlert = false
    let kStringWidth = 10.0
    @Published var stringNumber:Int     = 0
    @Published var formerZone           = -1
    @Published var zoneBreaks:[Double]  = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    @Published var audioPlayerArray     = [AVAudioPlayer?]() // contains 1 audioPlayer for each guitar string 6-1
    @Published var noteNamesArray       = ["DoubleLow_C.wav", "DoubleLow_C#.wav", "DoubleLow_D.wav", "DoubleLow_D#.wav", "Low_E.wav", "Low_F.wav", "Low_F#.wav", "Low_G.wav", "Low_G#.wav", "Low_A.wav", "Low_A#.wav", "Low_B.wav", "Low_C.wav", "Low_C#.wav", "Low_D.wav", "Low_D#.wav", "E.wav", "F.wav", "F#.wav", "G.wav", "G#.wav", "A.wav", "A#.wav", "B.wav", "C.wav", "C#.wav", "D.wav", "D#.wav", "High_E.wav", "High_F.wav", "High_F#.wav", "High_G.wav", "High_G#.wav", "High_A.wav", "High_A#.wav", "High_B.wav", "High_C.wav", "High_C#.wav", "High_D.wav", "High_D#.wav", "DoubleHigh_E.wav", "DoubleHigh_F.wav"]
    var stringsXlocations: [CGPoint] = []
    
    func playWaveFile(noteName: String,
                      stringNumber: Int,
                      volume: Double) {
        let prefix = String(noteName.prefix(noteName.count - 4))  // trims ".wav" from end
        
        debugPrint("====> playing String: \(stringNumber) note: \(noteName)")
        
        if let asset = NSDataAsset(name:prefix) {
            do {
                let thisAudioPlayer                 = try AVAudioPlayer(data:asset.data, fileTypeHint:"wav")
                audioPlayerArray[6 - stringNumber]  = thisAudioPlayer
                thisAudioPlayer.volume              = Float(volume) / 3.0
                
                thisAudioPlayer.prepareToPlay()
                thisAudioPlayer.play()
            }
            catch InitializeErrors.AVAudioSessionError{
                showAudioPlayerErrorAlert = true
            }
            catch {
                showAudioPlayerErrorAlert = true
            }
        }
    }
    
    func initializeAVAudioSession() {
        do {
            // Attempts to activate session so you can play audio,
            // if other sessions have priority this will fail
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            showAudioPlayerErrorAlert = true
            debugPrint(error)
        }
    }

    func loadWaveFilesIntoAudioPlayers() {
        for _ in 0...5 {
            if let asset = NSDataAsset(name:"NoNote"){
                do {
                    let thisAudioPlayer = try AVAudioPlayer(data:asset.data, fileTypeHint:"wav")
                    if thisAudioPlayer.isPlaying {
                        showAudioPlayerInUseAlert = true
                    }
                    audioPlayerArray.append(thisAudioPlayer)
                } catch InitializeErrors.AVAudioSessionError{ fatalError() }
                catch {
                    showAudioPlayerErrorAlert = true
                    fatalError()
                }
            }
        }
    }

    init() {
        initializeAVAudioSession()
        loadWaveFilesIntoAudioPlayers()
    }
    
    func getZone(loc: CGPoint) -> Int{
        // ZoneBreaks[n] is leftmost position of string[6-n]
        var zone = 0
        if loc.x < zoneBreaks[0] {
            zone = 0
        } else if loc.x <= zoneBreaks[0] + kStringWidth {
            zone = 1 // over string 6
        } else if loc.x < zoneBreaks[1] {
            zone = 2  // between string 6 and string 5
        } else if loc.x <= zoneBreaks[1] + kStringWidth {
            zone = 3 // over string 5
        } else if loc.x < zoneBreaks[2] {
            zone = 4  // between string 5 and string 4
        } else if loc.x <= zoneBreaks[2] + kStringWidth {
            zone = 5 // over string 4
        } else if loc.x < zoneBreaks[3] {
            zone = 6  // between string 4 and string 3
        } else if loc.x <= zoneBreaks[3] + kStringWidth {
            zone = 7 // over string 3
        } else if loc.x < zoneBreaks[4] {
            zone = 8  // between string 3 and string 2
        } else if loc.x <= zoneBreaks[4] + kStringWidth {
            zone = 9 // over string 2
        } else if loc.x < zoneBreaks[5] {
            zone = 10  // between string 2 and string 1
        } else if loc.x <= zoneBreaks[5] + kStringWidth {
            zone = 11 // over string 1
        } else {
            zone = 12  // right of string 1
        }
        
        return zone
    }
}
