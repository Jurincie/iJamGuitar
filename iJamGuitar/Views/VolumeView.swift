//
//  VolumeView.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 4/29/22.
//

import SwiftUI

struct VolumeView: View {
    @EnvironmentObject var model: iJamGuitarModel
    @State private var isEditing = false
    var imageWidth = UIDevice.current.userInterfaceIdiom == .pad ? 35.0 : 25.0
    
    func VolumeSlider() -> some View {
        Slider(
            value: $model.volumeLevel,
            in: 0...10,
            onEditingChanged: { editing in
                isEditing = editing
                if isEditing == false {
                    model.appState?.volumeLevel = NSDecimalNumber(value: model.volumeLevel)
                    try? model.context.save()
                }
            })
    }
    
    func SpeakerImage() -> some View {
        Image(systemName: model.isMuted ? "speaker.slash.fill" : "speaker.wave.1")
            .resizable()
            .frame(width: imageWidth, height: imageWidth)
            .shadow(radius: 10)
            .foregroundColor(Color.white)
            .padding(10)
    }
    
    var body: some View {
        VStack() {
            Spacer()
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    model.isMuted.toggle()
                    updateIsMuted()
                    try? model.context.save()
                }) {
                    SpeakerImage()
                }
                VolumeSlider()
                Spacer()
            }
            Spacer()
        }
    }
    
    func updateIsMuted() {
        model.appState?.isMuted = model.isMuted
       
        if (model.isMuted) {
            // save volume level and set to zero
            model.savedVolumeLevel = model.volumeLevel
            model.volumeLevel = 0.0
            model.appState?.volumeLevel = 0.0
        }
        else {
            // restore volume level if user hasn't changed it from zero
            if model.volumeLevel == 0.0 {
                model.volumeLevel = model.savedVolumeLevel
                model.appState?.volumeLevel = NSDecimalNumber(value: model.volumeLevel)
            }
        }
    }
}

