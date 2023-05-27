//
//  ChordButtonsView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/25/22.
//

import SwiftUI

struct ChordButtonsView: View {
    @EnvironmentObject var iJamGuitarMoodel: iJamGuitarModel
    var width:CGFloat = 0.0
    var height:CGFloat = 0.0
    let mySpacing:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 36.0 : 12.0
    private let columns = Array(repeating: GridItem(.flexible()), count: 5)
    private var activeButtonId: Int = -1
    
    func getPicks() -> [Pick] {
        let chordNames:[String] = iJamGuitarMoodel.getAvailableChordNames(activeChordGroup: iJamGuitarMoodel.activeChordGroup)
        var pickArray: [Pick] = []
        
        for index in 0..<10 {
            pickArray.append(Pick(id: index, title: chordNames[index], image:Image("UndefinedPick")))
        }
        
        return pickArray
    }
            
    var body: some View {
        LazyVGrid(columns: columns, spacing:mySpacing) {
                ForEach(getPicks(), id: \.id) { pick in
                    PickView(pick: pick)
            }
        }
    }
        
    struct Pick: Identifiable  {
        var id: Int
        var title: String
        var image:Image
    }
    
    struct PickView: View {
        @EnvironmentObject var model: iJamGuitarModel
        @State private var isAnimated: Bool = false
        var pick: Pick
        let noChordArray = [Int](repeating: -1, count: 10)
        let kNoChordName = "NoChord"
        
        var body: some View {
            ZStack() {
                // background layer
                getPickButton()
                
                // front layer
                Text(self.pick.title == kNoChordName ? "" : self.pick.title)
                    .foregroundColor(Color.white)
                    .font(.custom("Arial Rounded MT Bold", size: getFontSize(targetString: self.pick.title)))
            }
            .cornerRadius(10.0)
            .rotationEffect(Angle(degrees: self.pick.title == kNoChordName ? 0 : isAnimated ? 360 : 0))
            .shadow(color: Color.white, radius: 20.0)
        }
        
        func getPickButton() -> some View {
           let button =  Button(action: {
                if model.selectedChordIndex != pick.id {
                    withAnimation(.default) {
                        isAnimated.toggle()
                    }
                    setNewActiveChord()
                }
            }){
                Image(getPickImageName())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 100.0)
                    .padding(10)
                    .opacity(self.pick.title == kNoChordName ? 0.3 : 1.0)
                    .disabled(self.pick.title == kNoChordName)
            }
            
            return button
        }
        
        // returns approprieate imageName for pickButton or "BlankPick" on failure
        func getPickImageName() -> String {
            var pickImageName = "BlankPick"
            if model.selectedChordIndex == self.pick.id {
                let thisChord = model.availableChords[self.pick.id]
                pickImageName =  model.fretIndexMap != model.getFretIndexMap(chord: thisChord) ? "ModifiedPick" : "ActivePick"
            } else {
                pickImageName = self.pick.id < model.availableChords.count ? "BlankPick" : "UndefinedPick"
            }
            
            return pickImageName
        }
        
        /// sets model.activeChord and model.selectedIndex
        func setNewActiveChord() {
            if let chordNames = model.activeChordGroup?.availableChordNames?.components(separatedBy: ["-"]) {
                if self.pick.id < chordNames.count {
                    let newActiveChordName = chordNames[self.pick.id]
                    if let newActiveChord = model.getChord(name: newActiveChordName, tuning: model.activeTuning) {
                        model.activeChord = newActiveChord
                        model.selectedChordIndex = self.pick.id
                    }
                    try? model.context.save()
                }
                isAnimated.toggle()
            }
        }
        
        func getFontSize(targetString:String) -> Double {
            
            switch targetString.count {
            case 1:     return UIDevice.current.userInterfaceIdiom == .pad ? 28.0 : 22.0
            case 2:     return UIDevice.current.userInterfaceIdiom == .pad ? 26.0 : 20.0
            case 3:     return UIDevice.current.userInterfaceIdiom == .pad ? 24.0 : 18.0
            case 4, 5:  return UIDevice.current.userInterfaceIdiom == .pad ? 18.0 : 14.0
            default:    return UIDevice.current.userInterfaceIdiom == .pad ? 14.0 : 10.0
            }
        }
    }
}

