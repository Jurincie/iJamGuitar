//
//  ChordButtonsView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/25/22.
//

import SwiftUI

struct ChordButtonsView: View {
    @EnvironmentObject var iJamGuitarVM: iJamGuitarViewModel
    var width:CGFloat   = 0.0
    var height:CGFloat  = 0.0
    let mySpacing:CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 36.0 : 12.0
    private let columns = Array(repeating: GridItem(.flexible()), count: 5)
    private var activeButtonId: Int = -1
    
    func getPicks() -> [Pick] {
        let chordNames:[String] = iJamGuitarVM.getAvailableChordNames(activeChordGroup: iJamGuitarVM.activeChordGroup)
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
    
    struct PulseButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 1.3 : 1.0)
        }
    }
    
    struct PickView: View {
        @EnvironmentObject var vm: iJamGuitarViewModel
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
            .rotationEffect(Angle(degrees: isAnimated ? 360 : 0))
            .shadow(color: Color.white, radius: 20.0)
        }
        
        func getPickButton() -> some View {
           return Button(action: {
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
    }
}

