//
//  StringView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 5/3/22.
//



import AVFoundation
import SwiftUI

///  StringsView
///  is responsible for displaying the 6 StringView views
///  and obtaining the bounds of each of the strings via their Anchor Preferences
///
/// StringsView moitors a DragGesture's position to track when to pluck a string to play its  Audio player
///
/// Zone 0:  left of string 6
/// Zone 1:  over String 6
/// Zone 2:  between Strings 6 - 5
/// Zone 3:  over String 5
/// Zone 4:  between Strings 5 - 4
/// Zone 5:  over String 4
/// Zone 6:  between Strings 4 - 3
/// Zone 7:  over String 3
/// Zone 8:  between Strings 3 - 2
/// Zone 9:  over String 2
/// Zone 10: between Strings 2 - 1
/// Zone 11: over String 1
/// Zone 12: right of String 1
///
struct StringsView: View {
    @EnvironmentObject var model: iJamGuitarModel
    let stringsVM = iJamAudioManager()
    @State var dragLocation: CGPoint?
    @State private var presentVolumeAlert = false
    var height: CGFloat = 0.0
    let kHalfStringWidh = 5.0
    let kNoFret = -1

    var body: some View {
        let tap = TapGesture().onEnded { stringsVM.formerZone = -1 }
            .onEnded({ location in
                print("Tapped at \(location)")
            })
        
         let drag = DragGesture(minimumDistance: 0).onChanged { drag in
            dragLocation = drag.location
            guard let location = dragLocation else { return }
            debugPrint("====> DragLocation: \(location)")
            
            let zone = stringsVM.getZone(loc: location)
            guard zone != stringsVM.formerZone else { return }
            debugPrint("====> In New Zone: \(zone)")
           
            if zone % 2 == 0 && model.appState?.isMuted == false {
                if(AVAudioSession.sharedInstance().outputVolume == 0.0) {
                    // Alert user that their volume is off
                    presentVolumeAlert = true
                }
                
                let stringToPlay: Int = stringsVM.stringNumberToPlay(zone: zone, oldZone: stringsVM.formerZone)
                guard stringToPlay > 0 && stringToPlay < 7 else { return }
                
                pickString(stringToPlay)
            }
            stringsVM.formerZone = zone
        }.sequenced(before: tap)

        HStack() {
            SixSpacerHStack()
            HStack(spacing:0) {
                StringView(height:height, stringNumber: 6, fretNumber: model.fretIndexMap[0]) .readFrame { newFrame in
                    stringsVM.zoneBreaks[0] = ((newFrame.maxX + newFrame.minX) / 2.0) - kHalfStringWidh
                }
                Spacer()
                StringView(height:height, stringNumber: 5, fretNumber: model.fretIndexMap[1]) .readFrame { newFrame in
                    stringsVM.zoneBreaks[1] = ((newFrame.maxX + newFrame.minX) / 2.0) - kHalfStringWidh
                }
                Spacer()
                StringView(height:height, stringNumber: 4, fretNumber: model.fretIndexMap[2]) .readFrame { newFrame in
                    stringsVM.zoneBreaks[2] = ((newFrame.maxX + newFrame.minX) / 2.0) - kHalfStringWidh
                }
            }
            HStack() {
                Spacer()
                StringView(height:height, stringNumber: 3, fretNumber: model.fretIndexMap[3]) .readFrame { newFrame in
                    stringsVM.zoneBreaks[3] = ((newFrame.maxX + newFrame.minX) / 2.0) - kHalfStringWidh
                }
                Spacer()
                StringView(height:height, stringNumber: 2, fretNumber: model.fretIndexMap[4]) .readFrame { newFrame in
                    stringsVM.zoneBreaks[4] = ((newFrame.maxX + newFrame.minX) / 2.0) - kHalfStringWidh
                }
                Spacer()
                StringView(height:height, stringNumber: 1, fretNumber: model.fretIndexMap[5]).readFrame { newFrame in
                    stringsVM.zoneBreaks[5] = ((newFrame.maxX + newFrame.minX) / 2.0) - kHalfStringWidh
                }
            }
            SixSpacerHStack()
        }
        .gesture(drag)
            .alert("Master Volume is OFF", isPresented: $presentVolumeAlert) {
                Button("OK", role: .cancel) { presentVolumeAlert = false }
            }
            .alert("Another app is using the Audio Player", isPresented: $model.showAudioPlayerInUseAlert) {
                Button("OK", role: .cancel) { model.showAudioPlayerInUseAlert = false }
            }
            .alert("Audio Player Error", isPresented: $model.showAudioPlayerErrorAlert) {
                Button("OK", role: .cancel) { fatalError() }
            }
    }
    
    func pickString(_ stringToPlay: Int) {
        let openNotes = model.appState?.activeTuning?.openNoteIndices?.components(separatedBy: "-")
        let fretPosition = model.fretIndexMap[6 - stringToPlay]
        if fretPosition > kNoFret {
            if let noteIndices = openNotes, let thisStringsOpenIndex = Int(noteIndices[6 - stringToPlay]) {
                let index               = fretPosition + thisStringsOpenIndex + model.capoPosition
                let noteToPlayName      = stringsVM.noteNamesArray[index]
                let volume              = model.appState?.volumeLevel?.doubleValue  ?? 0.0

                stringsVM.playWaveFile(noteName:noteToPlayName,
                                       stringNumber: stringToPlay,
                                       volume: volume / 10.0)
            }
        }
    }

    struct SixSpacerHStack: View {
        var body: some View {
            HStack() {
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
        }
    }
}


