//
//  Extensions.swift
//  iJamGuitar
//
//  Created by Ron Jurincie on 5/8/22.
//

import Foundation
import CoreData
import SwiftUI

extension StringView {
    func getFretBoxArray(minFret: Int, openStringNote: String) -> [FretBox] {
        var fretBoxArray:[FretBox] = []
        fretBoxArray.append(FretBox(id: 0, title: model.fretIndexMap[6 - stringNumber] == -1 ?
                                    "X" : getFretNoteTitle(openNote: openStringNote, offset: 0)))
        for index in Range(0...4) {
            fretBoxArray.append(FretBox(id: minFret + index, title: getFretNoteTitle(openNote: openStringNote, offset: index + minFret)))
        }
        return fretBoxArray
    }
    
    func getFretNoteTitle(openNote:String, offset:Int) -> String {
        if let index = self.notes.firstIndex(of: openNote) {
            var finalIndex = index + offset + model.capoPosition
            if finalIndex < 0 {
                finalIndex += 12
            }
            return self.notes[finalIndex % 12]
        }
        return "C"
    }
}

extension View {
  func readFrame(onChange: @escaping (CGRect) -> ()) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
              .preference(key: FramePreferenceKey.self, value: geometryProxy.frame(in: .global))
      }
    )
    .onPreferenceChange(FramePreferenceKey.self, perform: onChange)
  }
}
