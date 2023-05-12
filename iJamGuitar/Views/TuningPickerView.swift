//
//  TuningPickerView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 5/18/22.
//

import SwiftUI

struct TuningPickerView: View {
   
    @EnvironmentObject var vm:iJamGuitarViewModel

    var body: some View {
       VStack {
           Menu {
               Picker("Tunings", selection: $vm.activeTuningName) {
                   ForEach(vm.getTuningNames(), id: \.self) {
                       Text($0)
                   }
               }
               .labelsHidden()
               .pickerStyle(.menu)
               .frame(maxWidth: .infinity)
           } label: {
               Text("Tuning: \(vm.activeTuningName)")
                   .padding(10)
                   .font(UIDevice.current.userInterfaceIdiom == .pad ? .title2 : .caption)
                   .fontWeight(.semibold)
                   .background(Color.accentColor)
                   .foregroundColor(Color.white)
                   .cornerRadius(10.0)
                   .shadow(color: .white , radius: 2.0)
           }
       }
    }
}

