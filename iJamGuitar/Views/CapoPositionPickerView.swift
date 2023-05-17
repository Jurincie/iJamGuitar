//
//  CapoPositionPickerView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 5/17/22.
//

import SwiftUI

struct CapoPositionPickerView: View {
    @EnvironmentObject var vm:iJamGuitarViewModel
    
    let frets = Range(-2...5)
    let kLabelWidth = 40.0
    
    func getCapoLabel() -> some View {
        return Text("\(vm.capoPosition)")
            .font(UIDevice.current.userInterfaceIdiom == .pad ? .title2 : .caption)
            .fontWeight(.semibold)
            .padding()
            .background(Color.clear)
            .foregroundColor(Color.white)
            .cornerRadius(4.0)
            .shadow(color: .white , radius: 2.0)
    }

    var body: some View {
        VStack {
            Menu {
               Picker("Capo Position", selection: $vm.capoPosition) {
                   ForEach(frets, id: \.self) {
                       Text(String($0))
                   }
               }
               .pickerStyle(.menu)
           } label: {
               getCapoLabel()
           }
       }
    }
}
