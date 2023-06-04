//
//  ChordGroupPickerView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 5/17/22.
//

import SwiftUI

@available(iOS 16.0, *)
struct ChordGroupPickerView: View {
    @EnvironmentObject var model: iJamModel
    
    var body: some View {
        VStack {
            Menu {
                Picker("Chord Groups", selection: $model.activeChordGroupName) {
                    ForEach(model.getChordGroupNames(), id: \.self) {
                        Text($0)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
            } label: {
                Text(model.activeChordGroupName)
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

