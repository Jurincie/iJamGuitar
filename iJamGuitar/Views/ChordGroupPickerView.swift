//
//  ChordGroupPickerView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 5/17/22.
//

import SwiftUI

struct ChordGroupPickerView: View {
    @EnvironmentObject var vm:iJamGuitarViewModel
    
    var body: some View {
        VStack {
            Menu {
                Picker("Chord Groups", selection: $vm.activeChordGroupName) {
                    ForEach(vm.getChordGroupNames(), id: \.self) {
                        Text($0)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
            } label: {
                Text(vm.activeChordGroupName)
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

