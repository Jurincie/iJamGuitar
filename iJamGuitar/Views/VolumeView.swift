//
//  VolumeView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/29/22.
//

import SwiftUI

struct VolumeView: View {
    @EnvironmentObject var vm:iJamGuitarViewModel
    @State private var isEditing = false
    var imageSize = UIDevice.current.userInterfaceIdiom == .pad ? 35.0 : 25.0
    
    var body: some View {
        VStack() {
            Spacer()
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    vm.isMuted.toggle()
                    vm.appState?.isMuted = vm.isMuted
                   
                    if (vm.isMuted) {
                        // save volume level and set to zero
                        vm.savedVolumeLevel = vm.volumeLevel
                        vm.volumeLevel = 0.0
                        vm.appState?.volumeLevel = 0.0
                    }
                    else {
                        // restore volume level if user hasn't changed it from zero
                        if vm.volumeLevel == 0.0 {
                            vm.volumeLevel = vm.savedVolumeLevel
                            vm.appState?.volumeLevel = NSDecimalNumber(value: vm.volumeLevel)                        }
                    }
                    try? vm.context.save()
                }) {
                    Image(systemName: vm.isMuted ? "speaker.slash.fill" : "speaker.wave.1")
                        .resizable()
                        .frame(width: imageSize, height: imageSize)
                        .shadow(radius: 10)
                        .foregroundColor(Color.white)
                        .padding(10)
                }
                Slider(
                    value: $vm.volumeLevel,
                    in: 0...10,
                    onEditingChanged: { editing in
                        isEditing = editing
                        if isEditing == false {
                            vm.appState?.volumeLevel = NSDecimalNumber(value: vm.volumeLevel)
                            try? vm.context.save()
                        }
                    })
                Spacer()
            }
            Spacer()
        }
    }
}

