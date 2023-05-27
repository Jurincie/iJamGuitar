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
    @EnvironmentObject var model: iJamGuitarModel
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
        var fretBox: FretBox
        var stringNumber: Int
        @EnvironmentObject var model: iJamGuitarModel

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
                    try? model.context.save()
                }){
                    if(self.fretBox.id == 0)
                    {
                        // show a white peg on zeroFret
                        Image("Peg")
                            .resizable()
                    } else {
                        // red ball on freted fretBox
                        Image(model.fretIndexMap[6 - stringNumber] == fretBox.id ? "Redball" : "")
                            .resizable()
                    }
                }
                // foreground
                // show fretZero note names AND a possibly fretted fretBox
                if self.fretBox.id == 0 {
                    Text(self.fretBox.title)
                        .foregroundColor(Color.black)
                } else {
                    self.fretBox.id == model.fretIndexMap[6 - stringNumber] ?
                    Text(self.fretBox.title)
                        .foregroundColor(Color.white) :
                    Text("")
                        .font(.custom("Arial Rounded MT Bold", size: 18.0))
                }
            }
        }
    }
}

