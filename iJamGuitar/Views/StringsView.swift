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
    @StateObject private var stringsVM = StringsViewModel()
    @State var tapLocation: CGPoint?
    @State var dragLocation: CGPoint?
    @State private var presentVolumeAlert = false
    var height: CGFloat = 0.0
    let kHalfStringWidh = 5.0
    let kNoFret = -1

    var body: some View {
        let openNotes = model.appState?.activeTuning?.openNoteIndices?.components(separatedBy: "-")
        let tap = TapGesture().onEnded { stringsVM.formerZone = -1 }
        let drag = DragGesture(minimumDistance: 0).onChanged { value in
            dragLocation = value.location
            guard let location = dragLocation else { return }
            let zone = stringsVM.getZone(loc: location)
            guard zone != stringsVM.formerZone else { return }
            debugPrint("====> New Zone: \(zone)")

            if zone % 2 == 0 && model.appState?.isMuted == false {
                if(AVAudioSession.sharedInstance().outputVolume == 0.0) {
                    // Alert user that their volume is off
                    presentVolumeAlert = true
                }
                let stringToPlay: Int = stringNumberToPlay(zone: zone, oldZone: stringsVM.formerZone)
                guard stringToPlay > 0 && stringToPlay < 7 else { return }
                let fretPosition = model.fretIndexMap[6 - stringToPlay]
                if fretPosition > kNoFret {
                    if let noteIndices = openNotes,
                       let thisStringsOpenIndex    = Int(noteIndices[6 - stringToPlay]) {
                        let index                   = fretPosition + thisStringsOpenIndex + model.capoPosition
                        let noteToPlayName          = stringsVM.noteNamesArray[index]
                        let volume                  = model.appState?.volumeLevel?.doubleValue  ?? 0.0

                        stringsVM.playWaveFile(noteName:noteToPlayName,
                                               stringNumber: stringToPlay,
                                               volume: volume / 10.0)
                    }
                }
            }
            stringsVM.formerZone = zone
        }.sequenced(before: tap)

        HStack() {
            FiveSpacerHStack()
            HStack(spacing:0) {
                StringView(height:height, stringNumber: 6, fretNumber: model.fretIndexMap[0]) .readFrame { newFrame in
                    stringsVM.zoneBreaks[0] = ((newFrame.maxX + newFrame.minX) / 2.0) - 5.0
                }
                Spacer()
                StringView(height:height, stringNumber: 5, fretNumber: model.fretIndexMap[1]) .readFrame { newFrame in
                    stringsVM.zoneBreaks[1] = ((newFrame.maxX + newFrame.minX) / 2.0) - 5.0
                }
                Spacer()
                StringView(height:height, stringNumber: 4, fretNumber: model.fretIndexMap[2]) .readFrame { newFrame in
                    stringsVM.zoneBreaks[2] = ((newFrame.maxX + newFrame.minX) / 2.0) - 5.0
                }
            }
            HStack() {
                Spacer()
                StringView(height:height, stringNumber: 3, fretNumber: model.fretIndexMap[3]) .readFrame { newFrame in
                    stringsVM.zoneBreaks[3] = ((newFrame.maxX + newFrame.minX) / 2.0) - 5.0
                }
                Spacer()
                StringView(height:height, stringNumber: 2, fretNumber: model.fretIndexMap[4]) .readFrame { newFrame in
                    stringsVM.zoneBreaks[4] = ((newFrame.maxX + newFrame.minX) / 2.0) - 5.0
                }
                Spacer()
                StringView(height:height, stringNumber: 1, fretNumber: model.fretIndexMap[5]).readFrame { newFrame in
                    stringsVM.zoneBreaks[5] = ((newFrame.maxX + newFrame.minX) / 2.0) - 5.0
                }
            }
            FiveSpacerHStack()
        }.gesture(drag)
            .alert("Master Volume is OFF", isPresented: $presentVolumeAlert) {
                Button("OK", role: .cancel) { presentVolumeAlert = false }
            }
            .alert("Another app is using the Audio Player", isPresented: $stringsVM.showAudioPlayerInUseAlert) {
                Button("OK", role: .cancel) { stringsVM.showAudioPlayerInUseAlert = false }
            }
            .alert("Audio Player Error", isPresented: $stringsVM.showAudioPlayerErrorAlert) {
                Button("OK", role: .cancel) { fatalError() }
            }
    }
    
    struct FiveSpacerHStack: View {
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
    
    func stringNumberToPlay(zone: Int, oldZone: Int) -> Int {
        guard oldZone != -1  else { return 0 }
        // if moving to left play string to right
        // if moving to right play string to left
        var stringNumber = (6 - (zone / 2))
        if oldZone < zone && zone != 0 {
            stringNumber += 1
        }
        return stringNumber
    }
}


