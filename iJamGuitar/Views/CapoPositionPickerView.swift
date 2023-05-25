//
//  CapoPositionPickerView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 5/17/22.
//

import SwiftUI

struct CapoPositionPickerView: View {
    @EnvironmentObject var model: iJamGuitarModel
    
    let frets = Range(-2...5)
    let kLabelWidth = 40.0
    
    func getCapoLabel() -> some View {
        return Text("\(model.capoPosition)")
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
               Picker("Capo Position", selection: $model.capoPosition) {
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
