//
//  StringView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 5/5/22.
//

import Foundation
import SwiftUI

// StringView has 2 layers:
//  bottom layer: appropriate string image
//  top layer:  VStack() of 6 possibly-RedBall images evenly spaced over top half of the stringsView

struct StringView: View {
    @EnvironmentObject var model: iJamModel
    let notes = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
    var height: CGFloat
    var stringImageName: String
    var stringNumber: Int
    
    init(height: CGFloat, stringNumber: Int, fretNumber: Int) {
        self.height             = height
        self.stringNumber       = stringNumber
        self.stringImageName    = "String"
        stringImageName.append("\(stringNumber)")
    }
        
    var body: some View {
        let openNotesString = (model.appState?.activeTuning?.stringNoteNames)
        if let openNotes:[String] = openNotesString?.components(separatedBy: ["-"]) {
            let fretBoxes:[FretBox] = getFretBoxArray(minFret: model.minimumFret, openStringNote: openNotes[6 - stringNumber])
            // 1x6 grid of Buttons with noteName in text on top of the possible image
            // zero or one of the buttons may show the redBall image indicating string if fretted there
            VStack(spacing:0) {
                FretBoxView(fretBox: fretBoxes[0], stringNumber:stringNumber)
                    .frame(width: height / 10, height: height / 12, alignment: .top)
                FretBoxView(fretBox: fretBoxes[1], stringNumber:stringNumber)
                    .frame(width: height / 10, height: height / 12, alignment: .top)
                FretBoxView(fretBox: fretBoxes[2], stringNumber:stringNumber)
                    .frame(width: height / 10, height: height / 12, alignment: .top)
                FretBoxView(fretBox: fretBoxes[3], stringNumber:stringNumber)
                    .frame(width: height / 10, height: height / 12, alignment: .top)
                FretBoxView(fretBox: fretBoxes[4], stringNumber:stringNumber)
                    .frame(width: height / 10, height: height / 12, alignment: .top)
                FretBoxView(fretBox: fretBoxes[5], stringNumber:stringNumber)
                    .frame(width: height / 10, height: height / 12, alignment: .top)
                
                Spacer()
            }
            .background(Image(stringImageName)
                .resizable()
                .frame(width:20, height:height, alignment:.topLeading)
                .opacity(model.fretIndexMap[6 - stringNumber] == -1 ? 0.3 : 1.0))
        }
    }
    
    struct FretBox: Identifiable  {
        var id: Int
        var title: String
    }
    
    struct FretBoxView: View {
        @EnvironmentObject var model: iJamModel
        var fretBox: FretBox
        var stringNumber: Int
        let context = PersistenceController.shared.container.viewContext

        var body: some View {
            let minFret = model.minimumFret
            ZStack() {
                // background
                Button(action:{
                    let currentFret = model.fretIndexMap[6 - stringNumber]
                    debugPrint("currentFret: \(currentFret)  minFret: \(minFret)  fretBoxID: \(fretBox.id)")
                    if currentFret == 0 && fretBox.id == 0 {
                        // if nut tapped when string open => make string muted
                        model.fretIndexMap[6 - stringNumber] = -1
                    } else if currentFret == fretBox.id {
                        // tapped existing fret => make string open
                        model.fretIndexMap[6 - stringNumber] = 0
                    } else {
                        // tap this fret
                        model.fretIndexMap[6 - stringNumber] = fretBox.id
                    }
                    try? context.save()
                }){
                    if(self.fretBox.id == 0)
                    {
                        // show a white circle on zeroFret with black text
                        CircleView(color: Color.teal, lineWidth: 1.0)
                    } else if model.fretIndexMap[6 - stringNumber] == fretBox.id {
                        // red ball on freted fretBox
                        // yellow ball if not in the chord - meaning user tapped on different fret
                        CircleView(color: fretIsFromChord() ? Color.red : Color.yellow, lineWidth: 1.0)
                    } else {
                        CircleView()
                    }
                }
                // foreground
                // show fretZero note names AND a (possibly) fretted fretBox
                if self.fretBox.id == 0 {
                    Text(self.fretBox.title)
                        .foregroundColor(Color.white)
                        .font(.footnote)
                } else {
                    let text = self.fretBox.id == model.fretIndexMap[6 - stringNumber] ? self.fretBox.title : ""
                    Text(text)
                        .foregroundColor(Color.black)
                        .font(.footnote)
                }
            }
        }
        
        func fretIsFromChord() -> Bool {
            guard stringNumber < 6 && stringNumber >= 0 else { return true }
            
            if let fretMap = model.activeChord?.fretMap {
                let index = fretMap.index(fretMap.startIndex, offsetBy: (6 - stringNumber))
                let chordFretNumber = model.getFretFromChar(fretMap[index])
                let currentFretNumber = model.fretIndexMap[6 - stringNumber]
                
                return currentFretNumber == chordFretNumber ? true : false
            }
            
            return true
        }
    }
}

struct CircleView: View {
    var color: Color
    var lineWidth: CGFloat
    
    init(color: Color = Color.clear, lineWidth: CGFloat = 0.0) {
        self.color = color
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(color)
            Circle()
                .strokeBorder(.black, lineWidth: lineWidth)
        }
        
    }
}

