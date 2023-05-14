//
//  ChordButtonsView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/25/22.
//

import SwiftUI

func getFontSize(targetString:String) -> Double {
    
    switch targetString.count {
    case 1:     return UIDevice.current.userInterfaceIdiom == .pad ? 28.0 : 22.0
    case 2:     return UIDevice.current.userInterfaceIdiom == .pad ? 26.0 : 20.0
    case 3:     return UIDevice.current.userInterfaceIdiom == .pad ? 24.0 : 18.0
    case 4, 5:  return UIDevice.current.userInterfaceIdiom == .pad ? 18.0 : 14.0
    default:    return UIDevice.current.userInterfaceIdiom == .pad ? 14.0 : 10.0
    }
}

func getPickTitle(name:String?) -> String {
    if let title = name {
        return title
    }
        
    return ""
}

struct ChordButtonsView: View {
    @EnvironmentObject var iJamGuitarVM: iJamGuitarViewModel
    var width:CGFloat   = 0.0
    var height:CGFloat  = 0.0
    let mySpacing:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 36.0 : 12.0
    private let columns = Array(repeating: GridItem(.flexible()), count: 5)
    private var activeButtonId: Int = -1

            
    var body: some View {
        let chordNames:[String] = iJamGuitarVM.getAvailableChordNames(activeChordGroup: iJamGuitarVM.activeChordGroup)
        
        let boxes = [Pick(id: 0, title: chordNames[0], image:Image("UndefinedPick")),
                      Pick(id: 1, title: chordNames[1], image:Image("UndefinedPick")),
                      Pick(id: 2, title: chordNames[2], image:Image("UndefinedPick")),
                      Pick(id: 3, title: chordNames[3], image:Image("UndefinedPick")),
                      Pick(id: 4, title: chordNames[4], image:Image("UndefinedPick")),
                      Pick(id: 5, title: chordNames[5], image:Image("UndefinedPick")),
                      Pick(id: 6, title: chordNames[6], image:Image("UndefinedPick")),
                      Pick(id: 7, title: chordNames[7], image:Image("UndefinedPick")),
                      Pick(id: 8, title: chordNames[8], image:Image("UndefinedPick")),
                      Pick(id: 9, title: chordNames[9], image:Image("UndefinedPick"))]
                
        LazyVGrid(columns: columns, spacing:mySpacing) {
                ForEach(boxes, id: \.id) { box in
                    PickView(pick: box)
            }
        }
    }
        
    struct Pick: Identifiable  {
        var id: Int
        var title: String
        var image:Image
    }
    
    struct PickView: View {
        @State private var isAnimated: Bool = false
        var pick: Pick
        @EnvironmentObject var vm: iJamGuitarViewModel
        let noChordArray = [Int](repeating: -1, count: 10)
        let kNoChordName = "NoChord"
        
        var body: some View {
            ZStack() {
                Button(action: {
                    if vm.selectedIndex != pick.id {
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
                Text(self.pick.title == kNoChordName ? "" : self.pick.title)
                    .foregroundColor(Color.white)
                    .font(.custom("Arial Rounded MT Bold", size: getFontSize(targetString: self.pick.title)))
            }
            .cornerRadius(10.0)
            .rotationEffect(Angle(degrees: isAnimated ? 360 : 0))
            .shadow(color: Color.white, radius: 20.0)
        }
        
        func getPickImageName() -> String {
            var pickImageName = ""
            if vm.selectedIndex == self.pick.id {
                let thisChord = vm.availableChords[self.pick.id]
                pickImageName =  vm.fretIndexMap != vm.getFretIndexMap(chord: thisChord) ? "ModifiedPick" : "ActivePick"
            } else {
                pickImageName = self.pick.id < vm.availableChords.count ? "BlankPick" : "UndefinedPick"
            }
            
            return pickImageName
        }
        
        /// sets vm.activeChord and vm.selectedIndex
        func setNewActiveChord() {
            if let chordNames = vm.activeChordGroup?.availableChordNames?.components(separatedBy: ["-"]) {
                if self.pick.id < chordNames.count {
                    let newActiveChordName = chordNames[self.pick.id]
                    if let newActiveChord = vm.getChord(name: newActiveChordName, tuning: vm.activeTuning) {
                        vm.activeChord = newActiveChord
                        vm.selectedIndex = self.pick.id
                    }
                    try? vm.context.save()
                }
                isAnimated.toggle()
            }
        }
    }
}

